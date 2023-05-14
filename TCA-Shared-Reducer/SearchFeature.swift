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
        var count: Int
        
        init(searchText: String = "", items: [String] = Array(0...20).map({String("Search Suggestion: \($0)")}), count: Int = 0) {
            self.searchText = searchText
            self.items = items
            self.count = count
        }
    }
    
    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)
        case onAppear
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.count += 1
                return .none
            default:
                return .none
            }
        }
    }
}

// MARK: - View
struct SearchView: View {
    let store: StoreOf<SearchFeature>
    
    init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
    
    var body: some View {
        let _ = Self._printChanges()
        WithViewStore(store, observe: {$0}) { viewStore in
            List {
                Section {
                    Text("\(viewStore.count)")
                } header: {
                    Text("OnAppear render count")
                }
                ForEach(viewStore.items, id: \.self) { item in
                    Text(item)
                }
            }
            .searchable(text: viewStore.binding(\.$searchText))
            .onAppear { viewStore.send(.onAppear) }
        }
    }
    
}
