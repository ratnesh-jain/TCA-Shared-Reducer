//
//  TabFeature.swift
//  TCA-Shared-Reducer
//
//  Created by Ratnesh Jain on 5/13/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
struct TabFeature: Reducer {
    enum State: Equatable, Identifiable {
        case listen(ListenFeature.State)
        case search(SearchFeature.State)
        
        var id: String {
            switch self {
            case .listen:
                return Tab.listen.rawValue
            case .search:
                return Tab.search.rawValue
            }
        }
    }
    enum Action: Equatable {
        case listen(ListenFeature.Action)
        case search(SearchFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.listen, action: /Action.listen) {
            ListenFeature()
        }
        Scope(state: /State.search, action: /Action.search) {
            SearchFeature()
        }
    }
}

// MARK: - View
struct TabFeatureView: View {
    let store: StoreOf<TabFeature>
    
    // Using the Environment we need to draw view with the same state, action.
    @Environment(\.playbackControlStore) private var playbackControlStore
    
    init(store: StoreOf<TabFeature>) {
        self.store = store
    }
    
    var body: some View {
        SwitchStore(store) {
            CaseLet(/TabFeature.State.listen, action: TabFeature.Action.listen) { listenStore in
                NavigationStack {
                    ListenView(store: listenStore)
                        .navigationTitle("Listen")
                        .safeAreaInset(edge: .bottom) {
                            PlaybackControlMiniView(store: playbackControlStore)
                        }
                }
                .tabItem {
                    Tab.listen.label
                }
            }
            CaseLet(/TabFeature.State.search, action: TabFeature.Action.search) { searchStore in
                NavigationStack {
                    SearchView(store: searchStore)
                        .navigationTitle("Search")
                        .safeAreaInset(edge: .bottom) {
                            PlaybackControlMiniView(store: playbackControlStore)
                        }
                }
                .tabItem {
                    Tab.search.label
                }
            }
        }
    }
}
