//
//  Request.swift
//
//
//  Created by Evan Anderson on 11/11/24.
//

import DestinyUtilities

/// Default storage for request data.
public struct Request : RequestProtocol {
    private let tokens:[SIMD64<UInt8>]
    private let headersBeginIndex:Int
    public let startLine:DestinyRoutePathType
    public let methodSIMD:SIMD8<UInt8>
    public let uri:DestinyRoutePathType
    public let version:HTTPVersion
    //public let body:String

    public lazy var method : HTTPRequestMethod? = {
        return HTTPRequestMethod.parse(methodSIMD)
    }()
    public lazy var path : [String] = {
        return uri.splitSIMD(separator: 47).map({ $0.leadingString() }) // 47 = /
    }()

    /// Temporary value; will be making it use SIMD in the near future
    public lazy var headers : any HTTPHeadersProtocol = { // TODO: make SIMD
        var string:String = ""
        string.reserveCapacity(tokens.count * 64)
        for i in 0..<tokens.count {
            string += tokens[i].leadingString()
        }
        let values = string.split(separator: "\r\n")
        guard values.count > 1 else { return HTTPRequestHeaders() }
        var dictionary:[String:String] = [:]
        dictionary.reserveCapacity(values.count-1)
        for i in 1..<values.count {
            let header = values[i]
            if let index = header.firstIndex(of: ":") {
                dictionary[String(header[header.startIndex..<index])] = String(header[header.index(index, offsetBy: 2)...])
            }
        }
        return HTTPRequestHeaders(dictionary)
    }()

    public lazy var query : [String:String] = {
        guard (uri .== .init(repeating: 63)) != .init(repeating: false), // make sure a question mark is present
                let targets:[DestinyRoutePathType] = uri.splitSIMD(separator: 63).getPositive(1)?.splitSIMD(separator: 38) // 63 -> ? | 38 -> &
        else {
            return [:]
        }
        var queries:[String:String] = [:]
        queries.reserveCapacity(targets.count)
        for var key in targets {
            let equalsIndex:Int = key.leadingNonByteCount(byte: 61) // 61 -> =
            var value = key
            // TODO: shift SIMD right `equalsIndex+1`
            value.keepLeading(value.leadingNonzeroByteCount)

            key.keepLeading(equalsIndex)
            queries[key.leadingString()] = value.stringSIMD()
        }
        return queries
    }()

    public func headersSIMD() {
        var headers:[SIMD64<UInt8>] = []
        headers.reserveCapacity(10)
        var values:[SIMD64<UInt8>] = []
        values.reserveCapacity(10)

        for var token in tokens {
            let crIndex = token.leadingNonByteCount(byte: 13) // \r
            if crIndex == 64 { // no carriage return in token
            } else { // carriage return in token
                token.keepLeading(crIndex-1)
                let colonIndex = token.leadingNonByteCount(byte: 58)
                if colonIndex != 64 { // has colon in token
                    var header = token
                    header.keepLeading(colonIndex-1)
                    headers.append(header)

                    var value = token
                    value.keepTrailing(64 - crIndex)
                    values.append(value)
                }
            }
        }
        for i in 0..<headers.count {
            print("headersSIMD;i=\(i);header=" + headers[i].leadingString() + ";value=" + values[i].trailingString())
        }
    }

    public init?(
        tokens: [SIMD64<UInt8>]
    ) {
        //print("Request.init;tokens=\n\(tokens.map { $0.stringSIMD() }.joined(separator: "\n"))")
        self.tokens = tokens
        guard var startLine = tokens.first else { return nil }
        let values = startLine.splitSIMD(separator: 32) // space
        guard let versionSIMD = values.getPositive(2), let version = HTTPVersion(versionSIMD) else {
            return nil
        }
        let firstCarriageReturnIndex = startLine.leadingNonByteCount(byte: 13) // \r
        headersBeginIndex = firstCarriageReturnIndex + 2
        //print("Utilities;Request;init;first_carriage_return_index=\(first_carriage_return_index);startLine=\(startLine.leadingString())")
        //print("shifted bytes=\((startLine &<< UInt8((first_carriage_return_index + 2) * 8)))")
        startLine.keepLeading(firstCarriageReturnIndex)
        self.startLine = startLine
        methodSIMD = values[0].lowHalf.lowHalf.lowHalf
        uri = values[1]
        self.version = version

        //headersSIMD()
    }

    public var description : String {
        return startLine.leadingString() + " (" + methodSIMD.leadingString() + "; " + uri.leadingString() + ";" + version.simd.leadingString() + ")"
    }
}