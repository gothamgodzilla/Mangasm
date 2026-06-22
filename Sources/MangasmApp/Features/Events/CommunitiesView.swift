import SwiftUI

// MARK: - CommunitiesView
// Spec §5.7 — Community cards with monogram, name, tag, member count, Join/Joined button, pride bar.
// Prototype: mangasm-events.jsx CommunitiesView + CommunityCard.
// Data: env.events.communities() — returns Community.samples (MockEventService).

struct CommunitiesView: View {
    @EnvironmentObject var env: AppEnvironment

    private var communities: [Community] {
        env.events.communities()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Section header
            HStack(alignment: .firstTextBaseline) {
                SectionLabel("LGBTQ+ COMMUNITIES")
                Spacer()
                Text("\(communities.count) near you")
                    .font(MGFont.mono(8))
                    .foregroundStyle(MGColor.inkFaint)
            }

            // Subtitle
            Text("Verified, member-moderated spaces. Join to see group chats, drops & member-only events.")
                .font(MGFont.sans(10, .light))
                .foregroundStyle(MGColor.inkSoft)
                .lineSpacing(4)
                .padding(.bottom, 13)

            // Community cards
            VStack(spacing: 10) {
                ForEach(communities) { community in
                    CommunityCard(community: community)
                }
            }
        }
    }
}

// MARK: - CommunityCard
// Holo-bordered card: monogram tile | name/tag/members | Join/Joined button | pride bar.
private struct CommunityCard: View {
    let community: Community
    @State private var joined: Bool = false

    // PRIDE gradient: red/orange/yellow/green/blue/purple (prototype PRIDE constant)
    private static let prideGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "#e40303"), location: 0.00),
            .init(color: Color(hex: "#ff8c00"), location: 0.22),
            .init(color: Color(hex: "#ffed00"), location: 0.42),
            .init(color: Color(hex: "#008026"), location: 0.62),
            .init(color: Color(hex: "#004dff"), location: 0.80),
            .init(color: Color(hex: "#750787"), location: 1.00),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        // Holo border wrapper
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(MGGradient.holo)
                .shadow(
                    color: Color(red: 40/255, green: 30/255, blue: 15/255).opacity(0.5),
                    radius: 18, x: 0, y: 12
                )

            VStack(spacing: 0) {
                HStack(spacing: 11) {
                    // Monogram tile
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(MGColor.gold.opacity(0.14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(MGColor.gold.opacity(0.33), lineWidth: 1)
                            )
                        Text(community.monogram)
                            .font(MGFont.serif(15, .bold))
                            .foregroundStyle(MGGradient.goldHeading)
                    }
                    .frame(width: 42, height: 42)

                    // Name / tag / members
                    VStack(alignment: .leading, spacing: 1) {
                        Text(community.name)
                            .font(MGFont.serif(15, .bold))
                            .foregroundStyle(MGColor.ink)
                            .lineLimit(1)
                        Text(community.tagline)
                            .font(MGFont.sans(9.5, .light))
                            .foregroundStyle(MGColor.inkSoft)
                        Text("\(community.memberCount) MEMBERS")
                            .font(MGFont.mono(7.5))
                            .tracking(7.5 * 0.08)
                            .foregroundStyle(MGColor.inkFaint)
                            .padding(.top, 3)
                    }

                    Spacer(minLength: 0)

                    // Join / Joined button
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) { joined.toggle() }
                    } label: {
                        Text(joined ? "Joined" : "Join")
                            .font(MGFont.serif(11.5, .bold))
                            .tracking(11.5 * 0.04)
                            .foregroundStyle(
                                joined
                                    ? AnyShapeStyle(MGColor.goldDeep)
                                    : AnyShapeStyle(MGColor.goldText)
                            )
                            .padding(.vertical, 7)
                            .padding(.horizontal, 14)
                            .background {
                                if joined {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(MGColor.gold.opacity(0.4), lineWidth: 1)
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(MGGradient.goldButton)
                                        .shadow(
                                            color: MGColor.gold.opacity(0.7),
                                            radius: 6, x: 0, y: 4
                                        )
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 11)

                // Pride gradient bar at bottom
                Self.prideGradient
                    .frame(height: 2.5)
                    .opacity(0.7)
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .glassBackground(15)
            .padding(1)
        }
    }
}
