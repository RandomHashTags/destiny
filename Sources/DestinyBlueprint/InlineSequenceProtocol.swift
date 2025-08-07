
/// Types conforming to this protocol indicate they're stored as an inline sequence.
public protocol InlineSequenceProtocol: Sendable, ~Copyable {
    associatedtype Element
}