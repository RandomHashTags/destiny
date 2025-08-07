
/// An `AsyncSequence` that stores an async stream that can be reused.
public struct ReusableAsyncThrowingStream<Element, E: Error>: AsyncSequence, Sendable {
    public typealias AsyncIterator = AsyncThrowingStream<Element, E>.Iterator

    public let source: @Sendable () -> AsyncThrowingStream<Element, E>

    public init(
        _ source: @Sendable @escaping () -> AsyncThrowingStream<Element, E>
    ) {
        self.source = source
    }

    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        source().makeAsyncIterator()
    }
}