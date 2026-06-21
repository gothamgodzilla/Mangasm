import SwiftUI

public struct MangasmRootView: View {
    @StateObject private var state = AppState()
    public init() {}
    public var body: some View {
        Group {
            switch state.phase {
            case .launch: PlaceholderScreen(title: "Mangasm — Launch")
            case .app:    MainTabView()
            }
        }
        .environmentObject(state)
    }
}
