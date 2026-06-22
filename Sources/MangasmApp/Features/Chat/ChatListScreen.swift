import SwiftUI

// MARK: - ChatListScreen
// Spec §5.6 — conversation list.
// Rows: avatar (gold ring), name (serif), last-message preview, time (mono), unread badge.
// Prototype ref: mangasm-chat.jsx (conversation list implied by ChatScreen pattern).
//
// onClose: called by an "X" button in the nav bar — sheet dismiss action.
// onOpen: called when a row is tapped.

public struct ChatListScreen: View {
    let onOpen: (Conversation) -> Void
    let onClose: () -> Void

    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var state: AppState

    public init(onOpen: @escaping (Conversation) -> Void, onClose: @escaping () -> Void) {
        self.onOpen = onOpen
        self.onClose = onClose
    }

    public var body: some View {
        ZStack {
            // Backdrop matches app aesthetic
            LamborghiniBackground(night: state.night)
            WeatherFX(kind: state.weather, night: state.night)

            VStack(spacing: 0) {
                // ── Header ────────────────────────────────────────────────────
                header

                // ── Conversation list ─────────────────────────────────────────
                let conversations = env.chat.conversations()
                if conversations.isEmpty {
                    Spacer()
                    Text("No conversations yet")
                        .font(MGFont.serif(16, .bold))
                        .foregroundStyle(MGColor.inkSoft)
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(conversations) { conversation in
                                ConversationRow(conversation: conversation) {
                                    onOpen(conversation)
                                }
                                Divider()
                                    .overlay(MGColor.gold.opacity(0.12))
                                    .padding(.leading, 68)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            // Glass background
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [.white.opacity(0.55), .clear],
                            startPoint: .top, endPoint: .center
                        ))
                        .blendMode(.overlay)
                        .allowsHitTesting(false)
                )
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(MGColor.gold.opacity(0.26))
                        .frame(height: 0.7)
                }
                .shadow(color: Color(red: 40/255, green: 30/255, blue: 15/255).opacity(0.28),
                        radius: 14, x: 0, y: 8)

            HStack(spacing: 10) {
                // Close button
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(MGColor.goldDeep)
                        .frame(width: 30, height: 30)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(MGColor.gold.opacity(0.33), lineWidth: 0.7)
                        )
                }
                .buttonStyle(.plain)

                Text("Messages")
                    .font(MGFont.serif(22, .bold))
                    .foregroundStyle(MGGradient.goldHeading)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 52)
            .padding(.bottom, 14)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - ConversationRow

private struct ConversationRow: View {
    let conversation: Conversation
    let onTap: () -> Void

    private var unreadCount: Int { conversation.unreadCount }

    // Relative time approximation from last message timestamp
    private var timeLabel: String {
        guard let last = conversation.messages.last else { return "" }
        let interval = Date().timeIntervalSince(last.timestamp)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        return "\(Int(interval / 86400))d"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                // Avatar with gold ring
                avatarView

                // Name + last message
                VStack(alignment: .leading, spacing: 3) {
                    Text(conversation.candidateName)
                        .font(MGFont.serif(16, .bold))
                        .foregroundStyle(MGColor.ink)
                        .lineLimit(1)

                    Text(conversation.lastMessagePreview)
                        .font(MGFont.sans(11.5, .regular))
                        .foregroundStyle(MGColor.inkSoft)
                        .lineLimit(1)
                }

                Spacer()

                // Time + unread badge
                VStack(alignment: .trailing, spacing: 5) {
                    Text(timeLabel)
                        .font(MGFont.mono(9))
                        .foregroundStyle(MGColor.inkFaint)

                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(MGFont.mono(9))
                            .foregroundStyle(.white)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(MGGradient.goldButton, in: Circle())
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(colors: [MGColor.goldBright, MGColor.goldDeep],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 2
                )
                .frame(width: 50, height: 50)
                .shadow(color: MGColor.gold.opacity(0.45), radius: 5, x: 0, y: 0)

            AsyncImage(url: conversation.candidateAvatarURL.flatMap { URL(string: $0) }) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle()
                        .fill(MGColor.gold.opacity(0.15))
                        .overlay(
                            Text(String(conversation.candidateName.prefix(1)))
                                .font(MGFont.serif(18, .bold))
                                .foregroundStyle(MGColor.goldDeep)
                        )
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
        }
        .frame(width: 50, height: 50)
    }
}
