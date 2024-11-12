//
//  Request.swift
//
//
//  Created by Evan Anderson on 11/11/24.
//

import HTTPTypes

public struct Request : RequestProtocol, ~Copyable {
    private let tokens:[SIMD64<UInt8>]
    private let headersBeginIndex:Int
    public let startLine:DestinyRoutePathType
    public let methodSIMD:StackString8
    public let uri:DestinyRoutePathType
    public let version:HTTPVersion
    //public let body:String

    public lazy var method : HTTPRequest.Method? = {
        return HTTPRequest.Method.parse(methodSIMD)
    }()
    public lazy var path : [String] = {
        return uri.splitSIMD(separator: 47).map({ $0.string() }) // 47 = /
    }()

    public lazy var headers : [StackString64:String] = {
        var dictionary:[StackString64:String] = [:]
        return dictionary
    }()

    public init?(
        tokens: [SIMD64<UInt8>]
    ) {
        self.tokens = tokens
        guard var startLine:SIMD64<UInt8> = tokens.first else { return nil }
        let values:[SIMD64<UInt8>] = startLine.splitSIMD(separator: 32) // space
        guard let versionSIMD:SIMD64<UInt8> = values.get(2) else { return nil }
        let first_carriage_return_index:Int = startLine.leadingNonByteCount(byte: 13) // \r
        headersBeginIndex = first_carriage_return_index + 2
        //print("Utilities;Request;init;first_carriage_return_index=\(first_carriage_return_index);startLine=\(startLine.string())")
        //print("shifted bytes=\((startLine &<< UInt8((first_carriage_return_index + 2) * 8)))")
        startLine.keepLeading(first_carriage_return_index)
        self.startLine = startLine.lowHalf
        methodSIMD = values[0].lowHalf.lowHalf.lowHalf
        uri = values[1].lowHalf
        version = HTTPVersion(versionSIMD.lowHalf)
    }

    public var description : String {
        return startLine.string() + " (" + methodSIMD.string() + "; " + uri.string() + ";" + version.token.string() + ")"
    }
}