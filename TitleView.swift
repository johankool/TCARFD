//
//  TitleView.swift
//  TCARFD
//
//  Created by Johan Kool on 13/02/2023.
//

import ComposableArchitecture
import SwiftUI

struct TitleView: View {
  let store: StoreOf<DocumentReducer>
  
  struct ViewState: Equatable {
    let text: String
  }
  
  var body: some View {
    WithViewStore(store, observe: { ViewState(text: $0.text) }) { viewStore in
      Text(viewStore.text)
        .font(.title)
    }
  }
}

struct TitleView_Previews: PreviewProvider {
  static var previews: some View {
    TitleView(store: .init(initialState: .init(), reducer: DocumentReducer()))
  }
}
