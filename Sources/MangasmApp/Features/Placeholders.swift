import SwiftUI

struct PlaceholderScreen: View {
    let title: String
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            Text(title).font(.title).foregroundStyle(.white)
        }
    }
}
