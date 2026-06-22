import SwiftUI

// MARK: - ChatThreadScreen
// Spec §5.6 — message thread for a single conversation.
// Prototype ref: mangasm-chat.jsx ChatScreen().
//
// Glass header: back button, avatar (gold ring), name, "Online · X away", match-% pill.
// E2E banner: "END-TO-END ENCRYPTED · PRIVACY ZONES ON"
// Bubbles: received (cream-white, left, left tail), sent (gold-gradient, right, right tail).
// Typing indicator: 3 pulsing dots.
// Composer: glass text field + gold circular send button.
//
// Approximation: matchPct and distanceLabel are resolved from Candidate.samples by
// candidateID. If the candidate is not in samples (e.g. a newly created conversation),
// matchPct defaults to "?" and distance to "nearby".

public struct ChatThreadScreen: View {
    let conversation: Conversation
    let onBack: () -> Void

    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var state: AppState

    @State private var messages: [Message] = []
    @State private var draft: String = ""
    @State private var showTyping: Bool = false

    // Resolve candidate from seed data for header metadata
    private var candidate: Candidate? {
        Candidate.samples.first { $0.id == conversation.candidateID }
    }

    private var matchPctLabel: String {
        candidate.map { "\($0.matchPct)%" } ?? "—"
    }

    private var distanceLabel: String {
        candidate?.distanceLabel ?? "nearby"
    }

    public init(conversation: Conversation, onBack: @escaping () -> Void) {
        self.conversation = conversation
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            // Translucent backdrop
            LamborghiniBackground(night: state.night)
            WeatherFX(kind: state.weather, night: state.night)

            VStack(spacing: 0) {
                // ── Glass header ────────────────────────────────────────────────
                threadHeader

                // ── E2E banner ──────────────────────────────────────────────────
                e2eBanner

                // ── Messages ────────────────────────────────────────────────────
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 13) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            if showTyping {
                                TypingIndicator()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        .padding(.bottom, 10)
                    }
                    .onChange(of: messages.count) {
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: showTyping) {
                        if showTyping {
                            withAnimation {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }

                // ── Composer ────────────────────────────────────────────────────
                composerBar
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            messages = env.chat.messages(for: conversation.id)
            if messages.isEmpty {
                messages = conversation.messages
            }
        }
    }

    // MARK: - Header

    private var threadHeader: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [.white.opacity(0.62), .clear],
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
                .shadow(color: Color(red: 40/255, green: 30/255, blue: 15/255).opacity(0.35),
                        radius: 14, x: 0, y: 10)

            HStack(alignment: .center, spacing: 11) {
                // Back button
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(MGColor.goldDeep)
                        .frame(width: 32, height: 32)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(MGColor.gold.opacity(0.44), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                // Avatar with gold ring
                ZStack {
                    Circle()
                        .stroke(MGColor.gold, lineWidth: 2)
                        .frame(width: 42, height: 42)
                        .shadow(color: MGColor.gold.opacity(0.45), radius: 5)

                    AsyncImage(url: conversation.candidateAvatarURL.flatMap { URL(string: $0) }) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Circle()
                                .fill(MGColor.gold.opacity(0.15))
                                .overlay(
                                    Text(String(conversation.candidateName.prefix(1)))
                                        .font(MGFont.serif(16, .bold))
                                        .foregroundStyle(MGColor.goldDeep)
                                )
                        }
                    }
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())
                }

                // Name + online status
                VStack(alignment: .leading, spacing: 2) {
                    Text(conversation.candidateName)
                        .font(MGFont.serif(19, .bold))
                        .foregroundStyle(MGColor.ink)
                        .lineLimit(1)

                    HStack(spacing: 5) {
                        Circle()
                            .fill(MGColor.spotify)
                            .frame(width: 6, height: 6)
                            .shadow(color: MGColor.spotify.opacity(0.8), radius: 3)

                        Text("Online · \(distanceLabel)")
                            .font(MGFont.mono(8))
                            .tracking(8 * 0.08)
                            .foregroundStyle(MGColor.inkSoft)
                    }
                }

                Spacer()

                // Match % pill
                HStack(spacing: 4) {
                    Text(matchPctLabel)
                        .font(MGFont.serif(13, .bold))
                        .foregroundStyle(MGGradient.goldHeading)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 9)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 11))
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(MGColor.gold.opacity(0.44), lineWidth: 1)
                )
            }
            .padding(.horizontal, 14)
            .padding(.top, 52)
            .padding(.bottom, 12)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - E2E Banner

    private var e2eBanner: some View {
        Text("END-TO-END ENCRYPTED · PRIVACY ZONES ON")
            .font(MGFont.mono(7.5))
            .tracking(7.5 * 0.14)
            .foregroundStyle(MGColor.inkSoft)
            .padding(.vertical, 5)
            .padding(.horizontal, 11)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 0.7))
            .padding(.vertical, 10)
    }

    // MARK: - Composer

    private var composerBar: some View {
        HStack(spacing: 9) {
            // Glass text field
            HStack(spacing: 8) {
                TextField("Message…", text: $draft)
                    .font(MGFont.sans(13, .medium))
                    .foregroundStyle(MGColor.ink)
                    .onSubmit { send() }

                // Send button — gold circular
                Button(action: send) {
                    ZStack {
                        Circle()
                            .fill(MGGradient.goldButton)
                            .frame(width: 36, height: 36)
                            .shadow(color: MGColor.gold.opacity(0.7), radius: 7, x: 0, y: 4)
                            .overlay(
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.white.opacity(0.5), .clear],
                                        startPoint: .top, endPoint: .center
                                    ))
                                    .allowsHitTesting(false)
                            )

                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 58/255, green: 44/255, blue: 8/255))
                            .offset(x: 1, y: -1)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
            .padding(.leading, 14)
            .padding(.trailing, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(MGColor.gold.opacity(0.44), lineWidth: 1)
            )
            .overlay(
                Capsule()
                    .fill(LinearGradient(
                        colors: [.white.opacity(0.7), .clear],
                        startPoint: .top, endPoint: .init(x: 0.5, y: 0.3)
                    ))
                    .allowsHitTesting(false)
            )
            .shadow(color: Color(red: 40/255, green: 30/255, blue: 15/255).opacity(0.12),
                    radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .padding(.bottom, 24)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(MGColor.gold.opacity(0.18))
                .frame(height: 0.7)
        }
    }

    // MARK: - Actions

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // Optimistic local append
        let newMsg = Message(
            id: UUID().uuidString,
            senderIsMe: true,
            text: text,
            timestamp: Date()
        )
        messages.append(newMsg)
        draft = ""

        // Persist via service
        env.chat.send(text, to: conversation.id)

        // Show typing indicator briefly
        showTyping = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            showTyping = false
        }
    }
}

// MARK: - ChatBubble

private struct ChatBubble: View {
    let message: Message

    // Pop-in entrance
    @State private var appeared = false
    // Floating animation state
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        HStack {
            if message.senderIsMe { Spacer(minLength: 60) }

            bubbleContent
                .scaleEffect(appeared ? 1 : 0.7)
                .opacity(appeared ? 1 : 0)
                .offset(y: floatOffset)
                .onAppear {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.68)) {
                        appeared = true
                    }
                    // Subtle float — repeating up/down with slight randomness per bubble
                    withAnimation(
                        .easeInOut(duration: 3.5 + Double(message.id.hashValue % 3))
                            .repeatForever(autoreverses: true)
                    ) {
                        floatOffset = message.senderIsMe ? -2.5 : -3
                    }
                }

            if !message.senderIsMe { Spacer(minLength: 60) }
        }
    }

    private var bubbleContent: some View {
        ZStack(alignment: message.senderIsMe ? .bottomTrailing : .bottomLeading) {
            // Main bubble body
            Text(message.text)
                .font(MGFont.sans(12.5, message.senderIsMe ? .semibold : .medium))
                .foregroundStyle(message.senderIsMe
                    ? Color(red: 58/255, green: 44/255, blue: 8/255)
                    : MGColor.ink)
                .padding(.vertical, 10)
                .padding(.horizontal, 13)
                .padding(message.senderIsMe ? .trailing : .leading, 5) // tail spacing
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(bubbleShapeStyle)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            message.senderIsMe
                                ? MGColor.gold.opacity(0.8)
                                : Color.white.opacity(0.7),
                            lineWidth: message.senderIsMe ? 1.0 : 0.7
                        )
                )
                .shadow(
                    color: message.senderIsMe
                        ? MGColor.gold.opacity(0.5)
                        : Color(red: 40/255, green: 30/255, blue: 15/255).opacity(0.3),
                    radius: 15, x: 0, y: 12
                )

            // Tail — small rotated square at bottom-right or bottom-left
            Rectangle()
                .fill(tailColor)
                .frame(width: 11, height: 11)
                .rotationEffect(.degrees(45))
                .offset(
                    x: message.senderIsMe ? -8 : 8,
                    y: 4
                )
                .overlay(
                    Rectangle()
                        .stroke(
                            message.senderIsMe
                                ? MGColor.gold.opacity(0.8)
                                : Color.white.opacity(0.7),
                            lineWidth: message.senderIsMe ? 1.0 : 0.7
                        )
                        .frame(width: 11, height: 11)
                        .rotationEffect(.degrees(45))
                        .offset(
                            x: message.senderIsMe ? -8 : 8,
                            y: 4
                        )
                )
        }
        .padding(message.senderIsMe ? .trailing : .leading, 9)
    }

    // Sent: gold gradient. Received: cream-white glass.
    private var bubbleShapeStyle: AnyShapeStyle {
        if message.senderIsMe {
            return AnyShapeStyle(LinearGradient(
                colors: [
                    Color(red: 248/255, green: 236/255, blue: 200/255, opacity: 0.85),
                    Color(red: 228/255, green: 201/255, blue: 126/255, opacity: 0.70)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        } else {
            return AnyShapeStyle(Color(red: 255/255, green: 253/255, blue: 249/255, opacity: 0.70))
        }
    }

    private var tailColor: Color {
        message.senderIsMe
            ? Color(red: 232/255, green: 201/255, blue: 126/255, opacity: 0.80)
            : Color(red: 255/255, green: 253/255, blue: 249/255, opacity: 0.70)
    }
}

// MARK: - TypingIndicator

private struct TypingIndicator: View {
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { idx in
                    TypingDot(delay: Double(idx) * 0.18)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.7), lineWidth: 0.7)
            )

            Spacer(minLength: 60)
        }
    }
}

private struct TypingDot: View {
    let delay: Double

    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.4

    var body: some View {
        Circle()
            .fill(Color(red: 42/255, green: 33/255, blue: 23/255, opacity: 0.5))
            .frame(width: 6, height: 6)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}
