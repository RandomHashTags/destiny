
import DestinyBlueprint

public struct HTTPStartLine: HTTPStartLineProtocol {
    public typealias Method = InlineArray<20, UInt8>
    public typealias RequestTarget = InlineArray<64, UInt8>

    public let method:Method
    public let methodCount:Int
    public let path:RequestTarget
    public let pathCount:Int
    public let version:InlineArray<8, UInt8>

    public let endIndex:Int

    public init(
        buffer: some InlineByteArrayProtocol
    ) throws(SocketError) {
        let (methodArray, methodSpaceIndex):(Method, Int) = buffer.firstSlice(separator: .space, defaultValue: 0)
        let (pathArray, pathSpaceIndex):(RequestTarget, Int) = buffer.firstSlice(separator: .space, defaultValue: 0, offset: methodSpaceIndex+1)
        let versionArray:InlineArray<8, UInt8> = buffer.slice(startIndex: pathSpaceIndex+1, endIndex: pathSpaceIndex+9, defaultValue: 0)
        guard let v = HTTPVersion(token: versionArray) else {
            throw SocketError.malformedRequest()
        }
        method = methodArray
        methodCount = methodSpaceIndex
        path = pathArray
        pathCount = methodSpaceIndex.distance(to: pathSpaceIndex)-1
        version = versionArray
        endIndex = pathSpaceIndex+9
    }
}