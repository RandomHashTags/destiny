
import DestinyBlueprint

public struct MacroExpansionWithDateHeader: StaticRouteResponderProtocol {
    public let value:StaticString
    public let bodyCount:String.UTF8View
    public let body:String.UTF8View

    public init(_ value: StaticString, body: String) {
        self.value = value
        bodyCount = String(body.count).utf8
        self.body = body.utf8
    }

    @inlinable
    func temporaryBuffer(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws -> Void) throws {
        var err:(any Error)? = nil
        value.withUTF8Buffer { valuePointer in
            bodyCount.withContiguousStorageIfAvailable { contentLengthPointer in
                body.withContiguousStorageIfAvailable { bodyPointer in
                    withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count + contentLengthPointer.count + 4 + bodyPointer.count, { buffer in
                        var i = 0
                        buffer.copyBuffer(valuePointer, at: &i)
                        // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                        var offset = 20
                        let dateSpan = HTTPDateFormat.nowInlineArray
                        for i in dateSpan.indices {
                            buffer[offset] = dateSpan[i]
                            offset += 1
                        }
                        for v in bodyCount {
                            buffer[i] = v
                            i += 1
                        }
                        buffer[i] = .carriageReturn
                        i += 1
                        buffer[i] = .lineFeed
                        i += 1
                        buffer[i] = .carriageReturn
                        i += 1
                        buffer[i] = .lineFeed
                        i += 1
                        buffer.copyBuffer(bodyPointer, at: &i)
                        do {
                            try closure(buffer)
                            return
                        } catch {
                            err = error
                        }
                    })
                }
            }
            
        }
        if let err {
            throw err
        }
    }

    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try temporaryBuffer { buffer in
            try socket.writeBuffer(buffer.baseAddress!, length: buffer.count)
        }
    }
}