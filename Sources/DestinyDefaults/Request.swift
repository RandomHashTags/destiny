//
//  Request.swift
//
//
//  Created by Evan Anderson on 11/11/24.
//

import DestinyBlueprint
import DestinyUtilities

/// Default storage for request data.
public struct Request: RequestProtocol {
    public let path:[String]
    public let startLine:DestinyRoutePathType
    public let headers:HTTPRequestHeaders
    public let newStartLine:HTTPStartLine

    public var description: String {
        return ""
        //return startLine.leadingString() + " (" + methodSIMD.leadingString() + "; " + uri.leadingString() + ";" + version.simd.leadingString() + ")"
    }

    @inlinable
    public func forEachPath(offset: Int = 0, _ yield: (String) -> Void) {
        var i = offset
        while i < path.count {
            yield(path[i])
            i += 1
        }
    }

    @inlinable
    public func path(at index: Int) -> String {
        path[index]
    }

    @inlinable
    public var pathCount: Int {
        path.count
    }

    @inlinable
    public func isMethod<let count: Int>(_ method: InlineArray<count, UInt8>) -> Bool {
        method.stringRepresentationsAreEqual(newStartLine.method)
    }

    @inlinable
    public func header(forKey key: String) -> String? {
        headers[key]
    }
}

// MARK: Init
extension Request {
    @inlinable
    public init?<Socket: SocketProtocol & ~Copyable>(socket: borrowing Socket) throws {
        var path:[String] = []
        var headers:[String:String] = [:]
        var startLine:DestinyRoutePathType = .init()
        var newStartLine:HTTPStartLine! = nil
        while true {
            let (buffer, read) = try socket.readBuffer()
            if read <= 0 {
                break
            }
            //print("loadRequestLine;read=\(read)")

            newStartLine = try HTTPStartLine(buffer: buffer)
            path = newStartLine.path.string().split(separator: "/").map { String($0) }
            var pathIndex = 0
            for i in 0..<newStartLine.methodCount {
                startLine[pathIndex] = newStartLine.method[i]
                pathIndex += 1
            }
            startLine[pathIndex] = .space
            pathIndex += 1
            for i in 0..<newStartLine.pathCount {
                startLine[pathIndex] = newStartLine.path[i]
                pathIndex += 1
            }
            startLine[pathIndex] = .space
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
                separators: .carriageReturn, .lineFeed,
                defaultValue: 0,
                offset: newStartLine.endIndex + 2,
                yield: { slice in
                    if skip == 2 { // content
                    } else if slice == nextLine {
                        skip += 1
                    } else { // header
                        let (key, colonIndex):(InlineArray<256, UInt8>, Int) = slice.firstSlice(separator: .colon, defaultValue: 0)
                        let value:InlineArray<256, UInt8> = slice.slice(startIndex: colonIndex+2, endIndex: slice.endIndex, defaultValue: 0) //  skip the colon & adjacent space
                        headers[key.string()] = value.string()
                    }
                    //print("slice=\(slice.string())")
                }
            )*/
            if read < buffer.count {
                break
            }
        }
        self.newStartLine = newStartLine
        self.path = path
        self.headers = .init(headers)
        self.startLine = startLine
    }
}