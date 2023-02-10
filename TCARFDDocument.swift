//
//  TCARFDDocument.swift
//  TCARFD
//
//  Created by Johan Kool on 09/02/2023.
//

import Dependencies
import SQLite
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static var exampleText: UTType {
    UTType(importedAs: "com.example.plain-text")
  }
}

class TCARFDDocument: ReferenceFileDocument, Identifiable {
    
  static var readableContentTypes: [UTType] { [.exampleText] }

  required init(configuration: ReadConfiguration) throws {
    id = UUID()
    
    temporaryURL = URL.temporaryDirectory.appending(component: "\(id.uuidString)-current.sqlite")
    backupURL = URL.temporaryDirectory.appending(component: "\(id.uuidString)-backup.sqlite")
    
    try configuration.file.write(to: temporaryURL, originalContentsURL: nil)
    
    connection = try Connection(temporaryURL.path)
    backupConnection = try Connection(backupURL.path)
  }
  
  init() throws {
    id = UUID()
    
    let newDocumentURL = Bundle.main.url(forResource: "Untitled", withExtension: "sqlite")!
    
    temporaryURL = URL.temporaryDirectory.appending(component: "\(id.uuidString)-current.sqlite")
    backupURL = URL.temporaryDirectory.appending(component: "\(id.uuidString)-backup.sqlite")
    
    let data = try Data(contentsOf: newDocumentURL)
    try data.write(to: temporaryURL)
    
    connection = try Connection(temporaryURL.path)
    backupConnection = try Connection(backupURL.path)
  }
  
  func snapshot(contentType: UTType) throws -> Backup {
    try connection.backup(usingConnection: backupConnection)
  }
  
  func fileWrapper(snapshot: Backup, configuration: WriteConfiguration) throws -> FileWrapper {
    let backup = snapshot
    try backup.step()
    backup.finish()
    let data = try Data(contentsOf: backupURL)
    return .init(regularFileWithContents: data)
  }
  
  typealias ID = UUID
  let id: ID
  
  var undoManager: UndoManager?

  let temporaryURL: URL
  let backupURL: URL
  
  let connection: Connection
  let backupConnection: Connection
  
  func fetchText() throws -> String {
    let textsTable = Table("texts")
    let idColumn = Expression<Int64>("id")
    let textColumn = Expression<String>("text")
    
    // Simply always return text in row 1 for this demo
    let query = textsTable
      .filter(idColumn == 1)
      .limit(1)
    
    let rows = try connection
      .prepare(query)
    
    return rows.map { $0[textColumn] }.first ?? ""
  }
  
  func updateText(text: String) throws {
    let currentText = try fetchText()
    
    let textsTable = Table("texts")
    let idColumn = Expression<Int64>("id")
    let textColumn = Expression<String?>("text")
    let row1 = textsTable.filter(idColumn == 1)
    
    try connection.run(row1.update(textColumn <- text))
    
    undoManager?.registerUndo(withTarget: self, handler: {
      // Do what is needed to revert this change.
      try? $0.updateText(text: currentText)
      
      // Send the context of the change to the async stream.
      $0.continuation?.yield(.text)
    })
    undoManager?.setActionName("Update Text")
  }
  
  var didUndoRedo: AsyncStream<UndoContext> {
    AsyncStream { [weak self] continuation in
      self?.continuation = continuation
    }
  }
  
  private var continuation: AsyncStream<UndoContext>.Continuation?
  
  // Context is used so that reducers can ignore undo/redo events if the data change is not relevant to them.
  enum UndoContext: Sendable {
    case text
  }
}

extension DependencyValues {
  var document: TCARFDDocument {
    get { self[TCARFDDocumentKey.self] }
    set { self[TCARFDDocumentKey.self] = newValue }
  }
  
  enum TCARFDDocumentKey: TestDependencyKey {
    static var testValue = TCARFDDocument.mock
  }
}

extension TCARFDDocument {
  static var mock = try! TCARFDDocument()
}
