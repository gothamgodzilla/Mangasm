import SwiftUI

// MARK: - CompatRow
// Shared compatibility row used by AIMatchScreen and MatchDetailScreen.
// Single source of truth extracted from both files (previously duplicated as private).
// Prototype: Stat() component in mangasm-match.jsx.

struct CompatRow: View {
    let label: String
    let you: String
    let them: String
    let ok: Bool
    let note: String

    var body: some View {
        HStack(alignment: .center, spacing: 9) {
            // Checkmark circle
            ZStack {
                Circle()
                    .fill(ok
                        ? AnyShapeStyle(LinearGradient(
                            colors: [MGColor.goldBright, MGColor.goldDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing))
                        : AnyShapeStyle(MGColor.ink.opacity(0.12))
                    )
                if ok {
                    Image(systemName: "checkmark")
                        .font(.system(size: 6.5, weight: .bold))
                        .foregroundStyle(Color(red: 42/255, green: 29/255, blue: 5/255))
                }
            }
            .frame(width: 17, height: 17)

            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text(label)
                        .font(MGFont.mono(7.5))
                        .tracking(7.5 * 0.12)
                        .foregroundStyle(MGColor.inkFaint)
                    Spacer()
                    Text("\(you) × \(them)")
                        .font(MGFont.sans(10.5, .bold))
                        .foregroundStyle(MGColor.ink)
                }
                Text(note)
                    .font(MGFont.sans(9.5, .light))
                    .foregroundStyle(MGColor.inkSoft)
            }
        }
        .padding(.vertical, 7)
        .overlay(alignment: .top) {
            Divider().opacity(0.3)
        }
    }
}
