//
//  TCARFDApp.swift
//  TCARFD
//
//  Created by Johan Kool on 09/02/2023.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCARFDApp: App {
  var body: some Scene {
    DocumentGroup(
      newDocument: {
        try! TCARFDDocument()
      },
      editor: { configuration in
        let store = StoreOf<DocumentReducer>(initialState: .init(), reducer: DocumentReducer()) { dependencies in
          // Pass the document as a dependency, so any reducer can get data from the reference file document
          dependencies.document = configuration.document
        }
        ContentView(store: store)
      }
    )
  }
}
