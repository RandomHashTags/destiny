
import VariableLengthArray

// MARK: VLArray
extension VLArray where Element == UInt8 {
    /// - Returns: A case-literal `String` initialized from `storage`.
    #if Inlinable
    @inlinable
    #endif
    public func unsafeString() -> String {
        return String.init(unsafeUninitializedCapacity: storage.count, initializingUTF8With: {
            return $0.initialize(from: storage).index
        })
    }

    /// - Returns: A case-literal `String` initialized from `storage`.
    #if Inlinable
    @inlinable
    #endif
    public func unsafeString(offset: Int) -> String {
        let count = storage.count - offset
        let slice = storage[offset...]
        return String.init(unsafeUninitializedCapacity: count - offset, initializingUTF8With: {
            return $0.initialize(from: slice).index
        })
    }
}





// MARK: InlineArray





// MARK: HTTPSocketWritable
extension InlineArray: HTTPSocketWritable {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func write(to socket: some FileDescriptor) throws(SocketError) {
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

// MARK: BufferWritable
extension InlineArray where Element == UInt8 { 
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        for i in indices {
            buffer[index] = self[unchecked: i]
            index += 1
        }
    }
}

// MARK: string
extension InlineArray where Element == UInt8 {
    /// Efficiently initializes a `String` from `span`.
    /// 
    /// - Returns: A case-literal `String` initialized from `span`.
    #if Inlinable
    @inlinable
    #endif
    public func unsafeString() -> String {
        return self.span.withUnsafeBufferPointer { pointer in
            return String.init(unsafeUninitializedCapacity: pointer.count, initializingUTF8With: {
                return $0.initialize(from: pointer).index
            })
        }
    }

    /// Efficiently initializes a `String` from `span`.
    /// 
    /// - Returns: A case-literal `String` initialized from `span`.
    #if Inlinable
    @inlinable
    #endif
    public func unsafeString(offset: Int) -> String {
        return self.span.withUnsafeBufferPointer {
            let count = $0.count - offset
            let slice = $0[offset...]
            return String.init(unsafeUninitializedCapacity: count - offset, initializingUTF8With: {
                return $0.initialize(from: slice).index
            })
        }
    }
}