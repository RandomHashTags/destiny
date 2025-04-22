//
//  HTTPStartLine.swift
//
//
//  Created by Evan Anderson on 4/18/25.
//

import DestinyBlueprint

public struct HTTPStartLine : HTTPStartLineProtocol {
    public let method:InlineArray<20, UInt8>
    public let methodCount:Int
    public let path:InlineArray<64, UInt8>
    public let pathCount:Int
    public let version:InlineArray<8, UInt8>

    public let endIndex:Int
    public let httpVersion:HTTPVersion

    public init<let count: Int>(buffer: InlineArray<count, UInt8>) throws {
        // 32 = SPACE
        let (methodArray, methodSpaceIndex):(InlineArray<20, UInt8>, Int) = buffer.firstSlice(separator: 32, defaultValue: 0)
        let (pathArray, pathSpaceIndex):(InlineArray<64, UInt8>, Int) = buffer.firstSlice(separator: 32, defaultValue: 0, offset: methodSpaceIndex+1)
        let versionArray:InlineArray<8, UInt8> = buffer.slice(startIndex: pathSpaceIndex+1, endIndex: pathSpaceIndex+9, defaultValue: 0)
        guard let v = HTTPVersion(token: versionArray) else {
            throw SocketError.malformedRequest()
        }
        method = methodArray
        methodCount = methodSpaceIndex
        path = pathArray
        pathCount = methodSpaceIndex.distance(to: pathSpaceIndex)-1
        version = versionArray
        httpVersion = v
        endIndex = pathSpaceIndex+9
    }
}