//
//  SearchFeature.swift
//  TCA-Shared-Reducer
//
//  Created by Ratnesh Jain on 5/13/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
struct SearchFeature: Reducer {
    struct State: Equatable {
        @BindingState var searchText: String = ""
        var items: [String]
        
        init(searchText: String = "", items: [String] = Array(0...20).map({String("Search Suggestion: \($0)")})) {
            self.searchText = searchText
            self.items = items
        }
    }
    
    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}

// MARK: - View
struct SearchView: View {
    let store: StoreOf<SearchFeature>
    
    init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            List {
                ForEach(viewStore.items, id: \.self) { item in
                    Text(item)
                }
            }
            .searchable(text: viewStore.binding(\.$searchText))
        }
    }
    
}
