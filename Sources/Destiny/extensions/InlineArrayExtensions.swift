
import UnwrapArithmeticOperators
import VariableLengthArray

// MARK: VLArray
extension VLArray where Element == UInt8 {
    /// - Returns: A case-literal `String` initialized from `storage`.
    /// - Warning: The returned `String` is the exact size of this `VLArray`! This function doesn't look for a null-terminator!
    public func unsafeString() -> String {
        return String.init(unsafeUninitializedCapacity: storage.count, initializingUTF8With: {
            return $0.initialize(from: storage).index
        })
    }

    /// Efficiently initializes a `String` from `storage`.
    /// 
    /// - Returns: A case-literal `String` initialized from `storage` with start and end indexes.
    /// - Warning: `endIndex` MUST be greater than `startIndex`.
    public func unsafeString(startIndex: Int, endIndex: Int) -> String {
        let count = endIndex -! startIndex
        let slice = storage[startIndex..<endIndex]
        return String.init(unsafeUninitializedCapacity: count, initializingUTF8With: {
            return $0.initialize(from: slice).index
        })
    }
}





// MARK: InlineArray





// MARK: Write to file descriptor
extension InlineArray {
    public func write(to socket: borrowing some FileDescriptor & ~Copyable) throws(DestinyError) {
        var err:DestinyError? = nil
        withUnsafePointer(to: self, {
            do throws(DestinyError) {
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
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        for i in indices {
            buffer[index] = self[unchecked: i]
            index +=! 1
        }
    }
}

// MARK: string
extension InlineArray where Element == UInt8 {
    /// Efficiently initializes a `String` from `span`.
    /// 
    /// - Returns: A case-literal `String` initialized from `span`.
    /// - Warning: The returned `String` is the exact size of this `InlineArray`! This function doesn't look for a null-terminator!
    public func unsafeString() -> String {
        return self.span.withUnsafeBufferPointer { pointer in
            return String.init(unsafeUninitializedCapacity: pointer.count, initializingUTF8With: {
                return $0.initialize(from: pointer).index
            })
        }
    }

    /// Efficiently initializes a `String` from `span`.
    /// 
    /// - Returns: A case-literal `String` initialized from `span` with start and end indexes.
    /// - Warning: `endIndex` MUST be greater than `startIndex`.
    public func unsafeString(startIndex: Int, endIndex: Int) -> String {
        return self.span.withUnsafeBufferPointer {
            let count = endIndex -! startIndex
            let slice = $0[startIndex..<endIndex]
            return String.init(unsafeUninitializedCapacity: count, initializingUTF8With: {
                return $0.initialize(from: slice).index
            })
        }
    }
}

// MARK: HTTPSocketWritable
extension InlineArray: HTTPSocketWritable {}