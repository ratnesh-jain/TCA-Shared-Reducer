# TCA-Shared-Reducer
This is a toy project using [TCA](https://github.com/pointfreeco/swift-composable-architecture) to demonstrate sharing a common store through SwiftUI's environment.

## Use case:

<img width="220" alt="Screenshot 2023-05-13 at 3 46 20 PM" src="https://github.com/ratnesh-jain/TCA-Shared-Reducer/assets/117887125/4b3985da-bc08-4604-9ccd-b3d2dfb9874a">
<img width="222" alt="Screenshot 2023-05-13 at 3 46 38 PM" src="https://github.com/ratnesh-jain/TCA-Shared-Reducer/assets/117887125/e200df08-b5d8-4dab-a177-84c27e85592e">
<img width="221" alt="Screenshot 2023-05-13 at 3 46 51 PM" src="https://github.com/ratnesh-jain/TCA-Shared-Reducer/assets/117887125/40543e20-9417-4644-b138-fe5e4a70da5a">


- In above screenshots we have common player control view, that is displayed to all tabs using `.safeAreaInset` view modifier to display at the bottom edge of the view. 
- This view is having common state (and so common actions) but the this view's height does not propogate via `NavigationView`/`NavigationStack` as an additional safe area. Therefore, app is displaying these views as a seperate view to each tab item view and not above `TabView` itself.

  ```diff
  + @Environment(\.playbackControlStore) private var playbackControlStore
  ...

  CaseLet(/TabFeature.State.listen, action: TabFeature.Action.listen) { listenStore in
      NavigationStack {
          ListenView(store: listenStore)
              .safeAreaInset(edge: .bottom) {
  +               PlaybackControlMiniView(store: playbackControlStore)
              }
      }
      .tabItem {
          Tab.listen.label
      }
  }
  CaseLet(/TabFeature.State.search, action: TabFeature.Action.search) { searchStore in
      NavigationStack {
          SearchView(store: searchStore)
              .safeAreaInset(edge: .bottom) {
  +               PlaybackControlMiniView(store: playbackControlStore)
              }
      }
      .tabItem {
          Tab.search.label
      }
  }
  ```

- To derive the `playbackControlStore` which is in the `AppRootFeature`, app uses SwiftUI's environment to pass down to children views using below snippet. 

  ```swift
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
  ```
- App injects the the `playbackControlStore` at the `AppRootView`'s body as below snippet.

  ```diff
  init(store: StoreOf<AppRootFeature>) {
      self.store = store
  +   self.playbackControlStore = store.scope(state: \.playbackControl, action: AppRootFeature.Action.playbackControl)
  }

  var body: some View {
      WithViewStore(store, observe: {$0}) { viewStore in
          TabView {
              ...
          }
          .sheet(item: viewStore.binding(\.$destination)) { destination in
              switch destination {
              case .expanded:
                  PlaybackControlExpandedView(store: playbackControlStore)
              }
          }
  +        .environment(\.playbackControlStore, playbackControlStore)
      }
  }
  ```

## Inspection for body re-computing

- Get the knowledge of how the View's body get called when it environment changes. App uses aa `onAppear` modifier and increments a count in the each tab item feature state.

  ```diff
  struct State: Equatable {
  +     var count: Int
        
        init(...) { ... }
    }
    
    enum Action: Equatable {
  +     case onAppear
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
           switch action {
  +        case .onAppear:
  +           state.count += 1
  +           return .none
        ...
  ```
  
  and in the view,
  
  ```diff
  var body: some View {
  +     let _ = Self._printChanges()
        WithViewStore(store, observe: {$0}) { viewStore in
            List {
                Section {
  +                 Text("\(viewStore.count)")
                } header: {
                    Text("OnAppear render count")
                }
                ForEach(viewStore.items, id: \.self) { item in
                    Text(item)
                }
            }
  +         .onAppear{ viewStore.send(.onAppear) }
        }
    }
  ```
  
  By making these changes and running the app, `Self._printChanges()` prints
    ```
    ListenView: @self changed.
    ```
  every time the `body` is called. 
  
  
  These printing also occurs when clicking on the play/pause button in the `safeAreaInset` view which is observing `playbackControlStore` environment property.
  

  https://github.com/ratnesh-jain/TCA-Shared-Reducer/assets/117887125/30853681-09d4-4b5d-a490-d22b88946fdc

  
  But `.onAppear` change only appears when the view is actually disappeared when tapping on the other tab and not when clicking on play/pause button.
  

  https://github.com/ratnesh-jain/TCA-Shared-Reducer/assets/117887125/1f488e03-c120-44b6-a067-540dc32c36ea

  To confirm, moving `Self._printChanges()` inside `WithViewStore` results in the 
  ```
  ListenView: unchanged.
  ```

  https://github.com/ratnesh-jain/TCA-Shared-Reducer/assets/117887125/0257ad18-978a-43d5-ba4a-ecb91bf0b3b3

  I think, this is due to `WithViewStore` is hyper focused on the Reducer's state and it only renders when there is a change in reducer's state. 🤞
  
