//
//  HTTPStartLine.swift
//
//
//  Created by Evan Anderson on 4/18/25.
//

import DestinyBlueprint

public struct HTTPStartLine : HTTPStartLineProtocol {
    public let method:InlineArray<20, UInt8>
    public let path:InlineArray<64, UInt8>
    public let endIndex:Int
    public let version:HTTPVersion

    public init<let count: Int>(buffer: InlineArray<count, UInt8>) throws {
        let (methodArray, methodSpaceIndex):(InlineArray<20, UInt8>, Int) = buffer.firstSlice(separator: 32, defaultValue: 0)
        let (pathArray, pathSpaceIndex):(InlineArray<64, UInt8>, Int) = buffer.firstSlice(separator: 32, defaultValue: 0, offset: methodSpaceIndex+1)
        let (versionArray, versionEndIndex):(InlineArray<8, UInt8>, Int) = buffer.firstSlice(separator: 10, defaultValue: 0, offset: pathSpaceIndex+1)
        guard let v = HTTPVersion(token: versionArray) else {
            throw SocketError.malformedRequest()
        }
        method = methodArray
        path = pathArray
        version = v
        endIndex = versionEndIndex
    }
}