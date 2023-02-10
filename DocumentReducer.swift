//
//  DocumentReducer.swift
//  TCARFD
//
//  Created by Johan Kool on 09/02/2023.
//

import ComposableArchitecture
import Foundation

struct DocumentReducer: ReducerProtocol {
  struct State: Equatable {
    var text: String = "Initial data. If you see this, something is wrong!"
  }
  
  @Dependency(\.document) var document
  
  enum Action {
    case task(UndoManager)
    case loadData
    case addButtonTapped(String)
  }
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case let .task(undoManager):
      // Tell our document about its undo manager
      document.undoManager = undoManager
      
      return .run { send in
        // Initial load
        await send(.loadData)
        
        // Look for undo/redo events and trigger data reload
        for await context in document.didUndoRedo {
          switch context {
          case .text:
            // Only reload if it pertains to data this reducer is interested in
            await send(.loadData)
          }
        }
      }
      
    case .loadData:
      if let text = try? document.fetchText() {
        state.text = text
      }
      return .none
      
    case let .addButtonTapped(text):
      let newText = String(state.text.dropLast(1) + " and \(text)!")
      
      // Save data in our reference file document
      try? document.updateText(text: newText)
      
      state.text = newText
      return .none
    }
  }
}
