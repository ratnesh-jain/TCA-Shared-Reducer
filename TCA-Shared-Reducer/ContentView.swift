//
//  ContentView.swift
//  TCA-Shared-Reducer
//
//  Created by Ratnesh Jain on 5/13/23.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    let store: StoreOf<AppRootFeature>
    
    init() {
        self.store = .init(initialState: .init(), reducer: AppRootFeature())
    }
    
    var body: some View {
        AppRootView(store: store)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
