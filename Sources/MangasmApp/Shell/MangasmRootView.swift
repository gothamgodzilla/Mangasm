import SwiftUI

public struct MangasmRootView: View {
    @StateObject private var state = AppState()
    @StateObject private var env = AppEnvironment.makeDefault()
    @StateObject private var store = StoreKitStore()

    public init() {}

    public var body: some View {
        Group {
            switch state.phase {
            case .launch: LaunchFlow { state.enterApp() }
            case .app:    MainTabView()
            }
        }
        .environmentObject(state)
        .environmentObject(env)
        .environmentObject(store)
        // Propagate StoreKit entitlement into AppState.premium
        .onChange(of: store.isPremium) { _, isPremium in
            state.premium = isPremium
        }
        .task {
            await store.loadProducts()
            await store.updatePurchasedProducts()
        }
    }
}
