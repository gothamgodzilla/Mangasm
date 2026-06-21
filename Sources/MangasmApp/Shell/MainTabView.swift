import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        TabView(selection: $state.tab) {
            ForEach(AppTab.allCases) { tab in
                PlaceholderScreen(title: tab.rawValue.capitalized)
                    .tag(tab)
                    .tabItem { Text(tab.rawValue.capitalized) }
            }
        }
    }
}
