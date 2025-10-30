
import DestinyBlueprint
@testable import DestinyDefaults
@testable import DestinyEmbedded

/// Default storage for request data.
struct TestRequest: Sendable, ~Copyable {
    let fileDescriptor:TestFileDescriptor
    var _request:AbstractHTTPRequest<1024>

    init(
        fileDescriptor: TestFileDescriptor,
        _request: consuming AbstractHTTPRequest<1024>
    ) {
        self.fileDescriptor = fileDescriptor
        self._request = _request
    }

    func socketLocalAddress() -> String? {
        nil
    }
    func socketPeerAddress() -> String? {
        nil
    }

    mutating func forEachPath(
        offset: Int = 0,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        try _request.forEachPath(fileDescriptor: fileDescriptor, offset: offset, yield)
    }

    mutating func path(at index: Int) throws(SocketError) -> String {
        try _request.path(fileDescriptor: fileDescriptor, at: index)
    }

    mutating func pathCount() throws(SocketError) -> Int {
        try _request.pathCount(fileDescriptor: fileDescriptor)
    }

    mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        try _request.isMethod(fileDescriptor: fileDescriptor, method)
    }

    mutating func headers() throws(SocketError) -> [Substring:Substring] {
        try _request.headers(fileDescriptor: fileDescriptor)
    }
    mutating func header(forKey key: String) throws(SocketError) -> String? {
        try _request.header(fileDescriptor: fileDescriptor, forKey: key)
    }

    static func load(from socket: consuming some FileDescriptor & ~Copyable) throws(SocketError) -> TestRequest {
        .init(fileDescriptor: .init(fileDescriptor: socket.fileDescriptor), _request: .init())
    }

    func copy() -> Self {
        return Self(fileDescriptor: fileDescriptor, _request: _request.copy())
    }
}

// MARK: Start line
extension TestRequest {
    mutating func startLine() throws(SocketError) -> SIMD64<UInt8> {
        try _request.startLine(fileDescriptor: fileDescriptor)
    }

    mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        try _request.startLineLowercased(fileDescriptor: fileDescriptor)
    }
}

// MARK: Storage
extension TestRequest {
    mutating func loadStorage() throws(SocketError) {
        try _request.loadStorage(fileDescriptor: fileDescriptor)
    }
}