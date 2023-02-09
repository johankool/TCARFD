//
//  ContentView.swift
//  TCARFD
//
//  Created by Johan Kool on 09/02/2023.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
  let store: StoreOf<DocumentReducer>
  
  @Environment(\.undoManager) var undoManager
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text(viewStore.text)
          .font(.title)
        Spacer()
        VStack {
          Button {
            viewStore.send(.addButtonTapped("Blob"))
          } label: {
            Label("Blob", systemImage: "plus")
          }
          Button {
            viewStore.send(.addButtonTapped("Blob, Jr."))
          } label: {
            Label("Blob, Jr.", systemImage: "plus")
          }
          Button {
            viewStore.send(.addButtonTapped("Blob, Sr."))
          } label: {
            Label("Blob, Sr.", systemImage: "plus")
          }
          Button {
            viewStore.send(.addButtonTapped("Blob, Esq."))
          } label: {
            Label("Blob, Esq.", systemImage: "plus")
          }
        }
        .buttonStyle(.bordered)
        HStack {
          Button {
            undoManager?.undo()
          } label: {
            Label("Undo", systemImage: "arrow.uturn.backward.circle")
          }
          .keyboardShortcut("z", modifiers: [.command])
          .disabled(!(undoManager?.canUndo ?? false))
          Button {
            undoManager?.redo()
          } label: {
            Label("Redo", systemImage: "arrow.uturn.forward.circle")
          }
          .keyboardShortcut("z", modifiers: [.command, .shift])
          .disabled(!(undoManager?.canRedo ?? false))
        }
        .buttonStyle(.bordered)
      }
      .padding()
      .navigationBarTitleDisplayMode(.inline)
      .task {
        // Pass undo manager to the view store and start task looking for undo/redo events
        await viewStore.send(.task(undoManager)).finish()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(store: .init(initialState: .init(), reducer: DocumentReducer()))
  }
}
