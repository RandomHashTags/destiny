
/// Types conforming to this protocol indicate they're stored as an inline array.
public protocol InlineArrayProtocol: InlineCollectionProtocol, ~Copyable where Index == Int {
    init(repeating value: Element)

    func withUnsafeBufferPointer<E: Error, R>(_ body: (UnsafeBufferPointer<Element>) throws(E) -> R) throws(E) -> R
}

// MARK Conformances
extension InlineArray: InlineArrayProtocol, HTTPSocketWritable {
    @inlinable
    public func itemAt(index: Index) -> Element {
        self[index]
    }

    @inlinable
    public mutating func setItemAt(index: Int, element: Element) {
        self[index] = element
    }

    @inlinable
    public func withUnsafeBufferPointer<E: Error, R>(_ body: (UnsafeBufferPointer<Element>) throws(E) -> R) throws(E) -> R {
        var result:Result<R, E>! = nil
        span.withUnsafeBufferPointer {
            do throws(E) {
                result = .success(try body($0))
            } catch {
                result = .failure(error)
            }
        }
        switch result {
        case .success(let r): return r
        case .failure(let e): throw e
        case .none: fatalError("something went wrong")
        }
    }

    @inlinable
    public func write(to socket: Int32) throws(SocketError) {
        var err:SocketError? = nil
        withUnsafePointer(to: self, {
            do throws(SocketError) {
                try socket.socketWriteBuffer($0, length: count)
            } catch {
                err = error
            }
        })
        if let err {
            throw err
        }
    }
}

// MARK: Extensions
extension Array where Element: BinaryInteger {
    public init<T: InlineArrayProtocol>(_ inlineArray: T) where T.Index == Index, Element == T.Element {
        self = .init()
        reserveCapacity(inlineArray.count)
        for i in inlineArray.indices {
            append(inlineArray.itemAt(index: i))
        }
    }
}