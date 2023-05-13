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
        
        init(items: [String] = Array(0...20).map{String("Item: \($0)")}) {
            self.items = items
        }
    }
    
    enum Action: Equatable {
        
    }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

// MARK: - View
struct ListenView: View {
    let store: StoreOf<ListenFeature>
    
    init(store: StoreOf<ListenFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            List {
                ForEach(viewStore.items, id: \.self) { item in
                    Text(item)
                }
            }
        }
    }
}
