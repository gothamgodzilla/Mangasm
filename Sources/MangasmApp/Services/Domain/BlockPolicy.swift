import Foundation

/// Pure bidirectional block logic (Phase 4 — safety).
///
/// A block must hide BOTH users from each other regardless of who initiated it.
/// The verified audit found `isBlocked` was never bidirectional and never used to
/// filter Discover/Match/Chat — this type encodes the rule so every query layer
/// (mock and live) applies it identically.
public struct BlockPolicy: Sendable, Equatable {
    /// Directed edges: blocker -> set of blocked user ids.
    private var edges: [String: Set<String>] = [:]

    public init() {}

    public mutating func block(_ blocked: String, by blocker: String) {
        edges[blocker, default: []].insert(blocked)
    }

    public mutating func unblock(_ blocked: String, by blocker: String) {
        edges[blocker]?.remove(blocked)
    }

    /// True if either user has blocked the other (bidirectional visibility cut).
    public func isHidden(_ a: String, _ b: String) -> Bool {
        (edges[a]?.contains(b) ?? false) || (edges[b]?.contains(a) ?? false)
    }

    /// Remove anyone hidden relative to `viewer` from a candidate list.
    public func visible<T>(_ items: [T], viewer: String, id: (T) -> String) -> [T] {
        items.filter { !isHidden(viewer, id($0)) }
    }
}
