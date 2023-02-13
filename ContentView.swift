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
  
  struct ViewState: Equatable {
    let isUndoDisabled: Bool
    let isRedoDisabled: Bool
  }
  
  var body: some View {
    WithViewStore(store, observe: { _ in
      ViewState(
        isUndoDisabled: !(undoManager?.canUndo ?? false),
        isRedoDisabled: !(undoManager?.canRedo ?? false)
      )
    }) { viewStore in
      VStack {
        TitleView(store: store)
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
          .disabled(viewStore.isUndoDisabled)
          Button {
            undoManager?.redo()
          } label: {
            Label("Redo", systemImage: "arrow.uturn.forward.circle")
          }
          .keyboardShortcut("z", modifiers: [.command, .shift])
          .disabled(viewStore.isRedoDisabled)
        }
        .buttonStyle(.bordered)
      }
      .padding()
      .task {
        // Pass undo manager to the view store and start task looking for undo/redo events
        // Note that when running on macOS this is often nil
        // https://stackoverflow.com/questions/73430758/undomanager-environment-nil-until-view-change-swiftui
        await viewStore.send(.task(undoManager!)).finish()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(store: .init(initialState: .init(), reducer: DocumentReducer()))
  }
}
