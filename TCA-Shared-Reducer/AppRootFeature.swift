//
//  TabsReducer.swift
//  TCA-Shared-Reducer
//
//  Created by Ratnesh Jain on 5/13/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
struct AppRootFeature: Reducer {
    
    enum Destination: String, Equatable, Identifiable {
        case expanded
        
        var id: String {
            self.rawValue
        }
    }
    
    struct State: Equatable {
        var tabs: IdentifiedArrayOf<TabFeature.State>
        var playbackControl: PlaybackControlFeature.State
        @BindingState var destination: Destination?
        
        init() {
            self.tabs = .init(uniqueElements: [.listen(.init()), .search(.init())])
            self.playbackControl = .init()
        }
    }
    
    enum Action: Equatable, BindableAction {
        case tab(id: TabFeature.State.ID, action: TabFeature.Action)
        case playbackControl(PlaybackControlFeature.Action)
        case binding(_ action: BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.playbackControl, action: /Action.playbackControl) {
            PlaybackControlFeature()
        }
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .playbackControl(PlaybackControlFeature.Action.delegate(.openExpandedView)):
                state.destination = .expanded
                return .none
            default:
                return .none
            }
        }
        .forEach(\.tabs, action: /Action.tab) {
            TabFeature()
        }
    }
}

// MARK: - View
struct AppRootView: View {
    let store: StoreOf<AppRootFeature>
    let playbackControlStore: StoreOf<PlaybackControlFeature>
    
    init(store: StoreOf<AppRootFeature>) {
        self.store = store
        self.playbackControlStore = store.scope(state: \.playbackControl, action: AppRootFeature.Action.playbackControl)
    }
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            TabView {
                ForEachStore(store.scope(state: \.tabs, action: AppRootFeature.Action.tab)) { tabItemStore in
                    TabFeatureView(store: tabItemStore)
                }
            }
            // Not using `.sheet(store:state:action:content)` method since we already have `playbackControlStore` extracted in the init.
            .sheet(item: viewStore.binding(\.$destination)) { destination in
                switch destination {
                case .expanded:
                    PlaybackControlExpandedView(store: playbackControlStore)
                }
            }
            // Inserting `playbackControlStore` into environment.
            .environment(\.playbackControlStore, playbackControlStore)
        }
    }
}

// MARK: - Environment Key and Value extension for `playbackControlStore` sharing.
enum PlaybackControlStoreKey: EnvironmentKey {
    static var defaultValue: StoreOf<PlaybackControlFeature> = .init(initialState: .init(), reducer: PlaybackControlFeature())
}

extension EnvironmentValues {
    var playbackControlStore: StoreOf<PlaybackControlFeature> {
        get {
            self[PlaybackControlStoreKey.self]
        }
        set {
            self[PlaybackControlStoreKey.self] = newValue
        }
    }
}
