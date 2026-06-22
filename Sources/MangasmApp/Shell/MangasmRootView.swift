import SwiftUI

public struct MangasmRootView: View {
    @StateObject private var state = AppState()
    @StateObject private var env = AppEnvironment.mock
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
    }
}
