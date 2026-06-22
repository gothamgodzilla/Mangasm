import SwiftUI

public enum AppPhase { case launch, app }

public enum AppTab: String, CaseIterable, Identifiable {
    case discover, search, aiMatch, likes, profile
    public var id: String { rawValue }
}

@MainActor
public final class AppState: ObservableObject {
    @Published public var phase: AppPhase = .launch
    @Published public var tab: AppTab = .profile
    @Published public var night = false
    @Published public var premium = false
    @Published public var weather: Weather = .rain
    @Published public var selectedMatch: Candidate? = nil
    @Published public var activeChat: Conversation? = nil
    @Published public var showChatList: Bool = false
    @Published public var showSettings: Bool = false
    @Published public var profile: Profile = .sample
    @Published public var visibility: Visibility = .sample
    public init() {}
    public func enterApp() { phase = .app }

    /// Clears the local session after account deletion or sign-out: drops the
    /// in-memory profile/visibility, revokes premium, closes any open sheets, and
    /// returns to the launch flow. Sensitive in-memory data (fetishes, etc.) must
    /// not survive a deletion — server-side erasure is handled by the AuthService.
    public func resetForSignOut() {
        phase = .launch
        tab = .profile
        premium = false
        selectedMatch = nil
        activeChat = nil
        showChatList = false
        showSettings = false
        profile = .sample
        visibility = .sample
    }
}
