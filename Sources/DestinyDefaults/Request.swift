//
//  Request.swift
//
//
//  Created by Evan Anderson on 11/11/24.
//

import DestinyBlueprint
import DestinyUtilities

/// Default storage for request data.
public struct Request : RequestProtocol {
    public let path:[String]
    public let startLine:DestinyRoutePathType
    public let headers:HTTPRequestHeaders
    public let version:HTTPVersion
    public let method:HTTPRequestMethod?

    public var description : String {
        return ""
        //return startLine.leadingString() + " (" + methodSIMD.leadingString() + "; " + uri.leadingString() + ";" + version.simd.leadingString() + ")"
    }
}

// MARK: Init
extension Request {
    @inlinable
    public init?<T: SocketProtocol & ~Copyable>(socket: borrowing T) throws {
        var method:HTTPRequestMethod? = nil
        var path:[String] = []
        var version:HTTPVersion? = nil
        var headers:[String:String] = [:]
        var startLine:DestinyRoutePathType = .init()
        while true {
            let (buffer, read):(InlineArray<1024, UInt8>, Int) = try socket.readBuffer()
            if read <= 0 {
                break
            }
            //print("loadRequestLine;read=\(read)")
            // 58 = COLON
            // 32 = SPACE
            // 13 = \r
            // 10 = \n

            let newStartLine = try HTTPStartLine(buffer: buffer)
            guard let targetMethod = HTTPRequestMethod(newStartLine.method) else {
                throw SocketError.malformedRequest()
            }
            method = targetMethod
            path = newStartLine.path.string().split(separator: "/").map { String($0) }
            version = newStartLine.httpVersion
            var pathIndex = 0
            for i in 0..<newStartLine.methodCount {
                startLine[pathIndex] = newStartLine.method[i]
                pathIndex += 1
            }
            startLine[pathIndex] = 32
            pathIndex += 1
            for i in 0..<newStartLine.pathCount {
                startLine[pathIndex] = newStartLine.path[i]
                pathIndex += 1
            }
            startLine[pathIndex] = 32
            pathIndex += 1
            for i in 0..<8 {
                startLine[pathIndex] = newStartLine.version[i]
                pathIndex += 1
            }

            // performance falls off a cliff parsing headers; should we
            // just retain the buffer and record the start and end indexes
            // of things, with computed properties when and where necessary?

            /*var skip:UInt8 = 0
            let nextLine:InlineArray<256, UInt8> = .init(repeating: 0)
            let _:InlineArray<256, UInt8>? = buffer.split(
                separators: 13, 10,
                defaultValue: 0,
                offset: newStartLine.endIndex + 2,
                yield: { slice in
                    if skip == 2 { // content
                    } else if slice == nextLine {
                        skip += 1
                    } else { // header
                        let (key, colonIndex):(InlineArray<256, UInt8>, Int) = slice.firstSlice(separator: 58, defaultValue: 0)
                        let value:InlineArray<256, UInt8> = slice.slice(startIndex: colonIndex+2, endIndex: slice.endIndex, defaultValue: 0) //  skip the colon & adjacent space
                        headers[key.string()] = value.string()
                    }
                    //print("slice=\(slice.string())")
                }
            )*/
            if read < 1024 {
                break
            }
        }
        guard let method, let version else {
            throw SocketError.malformedRequest()
        }
        self.method = method
        self.path = path
        self.version = version
        self.headers = .init(headers)
        self.startLine = startLine
    }
}