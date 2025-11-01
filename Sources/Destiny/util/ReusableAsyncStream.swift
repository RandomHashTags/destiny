
/// An `AsyncSequence` that stores an async stream that can be reused.
public struct ReusableAsyncStream<Element>: AsyncSequence, Sendable {
    public typealias AsyncIterator = AsyncStream<Element>.Iterator

    public let source: @Sendable () -> AsyncStream<Element>

    public init(
        _ source: @Sendable @escaping () -> AsyncStream<Element>
    ) {
        self.source = source
    }

    public func makeAsyncIterator() -> AsyncIterator {
        source().makeAsyncIterator()
    }
}