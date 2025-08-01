
import DestinyBlueprint

public struct MacroExpansionWithDateHeader: StaticRouteResponderProtocol {
    public let value:String
    public let body:String

    public init(_ value: String, body: String) {
        self.value = value
        self.body = body
    }
    public init(_ response: HTTPResponseMessage) {
        value = (try? response.string(escapeLineBreak: true)) ?? ""
        if let b = response.body {
            body = "\(b)"
        } else {
            body = ""
        }
    }

    @inlinable
    func temporaryBuffer(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws -> Void) rethrows {
        try value.utf8.withContiguousStorageIfAvailable { valuePointer in
            let dateSpan = HTTPDateFormat.shared.nowInlineArray.span
            try String(body.count).utf8.withContiguousStorageIfAvailable { contentLengthPointer in
                try body.utf8.withContiguousStorageIfAvailable { bodyPointer in
                    try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count + contentLengthPointer.count + 4 + bodyPointer.count, { buffer in
                        var i = 0
                        buffer.copyBuffer(valuePointer, at: &i)
                        // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                        var offset = 20
                        for i in dateSpan.indices {
                            buffer[offset] = dateSpan[i]
                            offset += 1
                        }
                        contentLengthPointer.forEach {
                            buffer[i] = $0
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
                        try closure(buffer)
                    })
                }
            }
        }
    }

    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try temporaryBuffer { buffer in
            try socket.writeBuffer(buffer.baseAddress!, length: buffer.count)
        }
    }
}