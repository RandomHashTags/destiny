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
        return uri.splitSIMD(separator: 47).map({ $0.leadingString() }) // 47 = /
    }()

    /// Temporary value; will be making it use SIMD in the near future
    public lazy var headers : [String:String] = { // TODO: make SIMD
        var string:String = ""
        string.reserveCapacity(tokens.count * 64)
        for i in 0..<tokens.count {
            string += tokens[i].leadingString()
        }
        let values:[Substring] = string.split(separator: "\r\n")
        guard values.count > 1 else { return [:] }
        var dictionary:[String:String] = [:]
        dictionary.reserveCapacity(values.count-1)
        for i in 1..<values.count {
            let header:Substring = values[i]
            if let index:Substring.Index = header.firstIndex(of: ":") {
                dictionary[String(header[header.startIndex..<index])] = String(header[header.index(index, offsetBy: 2)...])
            }
        }
        return dictionary
    }()

    public func headersSIMD() {
        var headers:[SIMD64<UInt8>] = []
        headers.reserveCapacity(10)
        var values:[SIMD64<UInt8>] = []
        values.reserveCapacity(10)

        let carriage_returns:SIMD64<UInt8> = .init(repeating: 13)
        let absent_character:SIMDMask<SIMD64<UInt8>.MaskStorage> = .init(repeating: false)
        for token in tokens {
            if (token .== carriage_returns) == absent_character { // no carriage return in token
            } else { // carriage return in token
                let colon_index:Int = token.leadingNonByteCount(byte: 58)
                if colon_index != 64 { // has colon in token
                    var header:SIMD64<UInt8> = token, value:SIMD64<UInt8> = token
                    header.keepLeading(colon_index)
                    headers.append(header)
                }
            }
        }
    }

    public init?(
        tokens: [SIMD64<UInt8>]
    ) {
        self.tokens = tokens
        guard var startLine:SIMD64<UInt8> = tokens.first else { return nil }
        let values:[SIMD64<UInt8>] = startLine.splitSIMD(separator: 32) // space
        guard let versionSIMD:SIMD64<UInt8> = values.get(2) else { return nil }
        let first_carriage_return_index:Int = startLine.leadingNonByteCount(byte: 13) // \r
        headersBeginIndex = first_carriage_return_index + 2
        //print("Utilities;Request;init;first_carriage_return_index=\(first_carriage_return_index);startLine=\(startLine.leadingString())")
        //print("shifted bytes=\((startLine &<< UInt8((first_carriage_return_index + 2) * 8)))")
        startLine.keepLeading(first_carriage_return_index)
        self.startLine = startLine.lowHalf
        methodSIMD = values[0].lowHalf.lowHalf.lowHalf
        uri = values[1].lowHalf
        version = HTTPVersion(versionSIMD.lowHalf)
    }

    public var description : String {
        return startLine.leadingString() + " (" + methodSIMD.leadingString() + "; " + uri.leadingString() + ";" + version.token.leadingString() + ")"
    }
}