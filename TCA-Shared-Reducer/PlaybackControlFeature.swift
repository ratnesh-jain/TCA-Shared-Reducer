//
//  PlaybackControlFeature.swift
//  TCA-Shared-Reducer
//
//  Created by Ratnesh Jain on 5/13/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
struct PlaybackControlFeature: Reducer {
    struct State: Equatable {
        @BindingState var isPlaying: Bool = false
    }
    
    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case openExpandedView
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}

// MARK: - Playback Control MINI
struct PlaybackControlMiniView: View {
    let store: StoreOf<PlaybackControlFeature>
    
    init(store: StoreOf<PlaybackControlFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            HStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.secondary)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .shadow(radius: 8)
                    }
                
                Text("Not Playing")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    viewStore.send(.set(\.$isPlaying, !viewStore.isPlaying))
                } label: {
                    ZStack {
                        if viewStore.isPlaying {
                            Image(systemName: "pause.fill")
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "play.fill")
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.default, value: viewStore.isPlaying)
                    .font(.system(size: 44))
                }
            }
            .frame(height: 54)
            .padding()
            .background(Material.bar)
            .onTapGesture {
                viewStore.send(.delegate(.openExpandedView))
            }
        }
    }
}

struct PlaybackControlMiniView_Preview: PreviewProvider {
    static var previews: some View {
        PlaybackControlMiniView(store: .init(initialState: .init(), reducer: PlaybackControlFeature()))
    }
}

// MARK: - Playback Control Expanded
struct PlaybackControlExpandedView: View {
    let store: StoreOf<PlaybackControlFeature>
    
    init(store: StoreOf<PlaybackControlFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.secondary.opacity(0.5))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 120))
                            .foregroundColor(.white)
                            .shadow(radius: 12)
                    }
                
                Spacer()
                
                Text("Not Playing")
                
                Spacer()
                
                Button {
                    viewStore.send(.set(\.$isPlaying, !viewStore.isPlaying))
                } label: {
                    ZStack {
                        if viewStore.isPlaying {
                            Image(systemName: "pause.fill")
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "play.fill")
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.default, value: viewStore.isPlaying)
                    .font(.system(size: 44))
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct PlaybackControlExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            let store = StoreOf<PlaybackControlFeature>(initialState: .init(), reducer: PlaybackControlFeature())
            PlaybackControlExpandedView(store: store)
            PlaybackControlMiniView(store: store)
        }
    }
}
