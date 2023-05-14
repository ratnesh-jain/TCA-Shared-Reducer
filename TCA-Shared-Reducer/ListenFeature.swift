//
//  ListenFeature.swift
//  TCA-Shared-Reducer
//
//  Created by Ratnesh Jain on 5/13/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
struct ListenFeature: Reducer {
    struct State: Equatable {
        var items: [String]
        var count: Int
        
        init(items: [String] = Array(0...20).map{String("Item: \($0)")}, count: Int = 0) {
            self.items = items
            self.count = count
        }
    }
    
    enum Action: Equatable {
        case onAppear
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.count += 1
                return .none
            }
        }
    }
}

// MARK: - View
struct ListenView: View {
    let store: StoreOf<ListenFeature>
    
    init(store: StoreOf<ListenFeature>) {
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
            .onAppear{ viewStore.send(.onAppear) }
        }
    }
}
