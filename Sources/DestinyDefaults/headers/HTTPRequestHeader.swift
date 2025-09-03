
public enum HTTPRequestHeader {
}

// MARK: Accept-Encoding
extension HTTPRequestHeader {
    public struct AcceptEncoding: Sendable {
        public let compression:String
    }
}

// MARK: Range
extension HTTPRequestHeader {
    public enum Range: Sendable {
        case bytes(from: Int, to: Int)
    }
}

// MARK: X-Requested-With
extension HTTPRequestHeader {
    public enum XRequestedWith: String, Sendable {
        case xmlHttpRequest

        #if Inlinable
        @inlinable
        #endif
        public var rawName: String {
            switch self {
            case .xmlHttpRequest: "XMLHttpRequest"
            }
        }
    }
}