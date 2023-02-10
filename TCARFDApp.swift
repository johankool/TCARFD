//
//  TCARFDApp.swift
//  TCARFD
//
//  Created by Johan Kool on 09/02/2023.
//

import ComposableArchitecture
import SwiftUI

private var stores: [AnyHashable: StoreOf<DocumentReducer>] = [:]

@main
struct TCARFDApp: App {
  var body: some Scene {
    DocumentGroup(
      newDocument: {
        try! TCARFDDocument()
      },
      editor: { configuration in
        ContentView(store: {
          let id = configuration.document.id
          let store: StoreOf<DocumentReducer>
          if let existingStore = stores[id] {
            store = existingStore
          } else {
            store = StoreOf<DocumentReducer>(initialState: .init(), reducer: DocumentReducer()) { dependencies in
              // Pass the document as a dependency, so any reducer can get data from the reference file document
              dependencies.document = configuration.document
            }
            stores[id] = store
          }
          return store
        }())
        .onDisappear {
          let id = configuration.document.id
          stores.removeValue(forKey: id)
        }
      }
    )
  }
}
