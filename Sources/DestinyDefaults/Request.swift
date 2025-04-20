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
    public lazy var headers : HTTPRequestHeaders = { // TODO: make SIMD
        var string = ""
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
                let targets = uri.splitSIMD(separator: 63).getPositive(1)?.splitSIMD(separator: 38) // 63 -> ? | 38 -> &
        else {
            return [:]
        }
        var queries:[String:String] = [:]
        queries.reserveCapacity(targets.count)
        for var key in targets {
            let equalsIndex = key.leadingNonByteCount(byte: 61) // 61 -> =
            var value = key
            // TODO: shift SIMD right `equalsIndex+1`
            value.keepLeading(value.leadingNonzeroByteCount)

            key.keepLeading(equalsIndex)
            queries[key.leadingString()] = value.stringSIMD()
        }
        return queries
    }()

    @usableFromInline
    init?(
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
    }

    public var description : String {
        return startLine.leadingString() + " (" + methodSIMD.leadingString() + "; " + uri.leadingString() + ";" + version.simd.leadingString() + ")"
    }
}

// MARK: Init
extension Request {
    @inlinable
    public init?<T: SocketProtocol & ~Copyable>(socket: borrowing T) throws {
        var test:[SIMD64<UInt8>] = []
        test.reserveCapacity(16) // maximum of 1024 bytes; decent starting point
        while true {
            let (line, read):(SIMD64<UInt8>, Int) = try socket.readLineSIMD(length: 64)
            if read <= 0 {
                break
            }
            test.append(line)
            if read < 64 {
                break
            }
        }
        if test.isEmpty {
            return nil
        }
        guard let request = Self.init(tokens: test) else {
            throw SocketError.malformedRequest()
        }
        self = request
    }
    @inlinable
    public init?<T: SocketProtocol & ~Copyable>(socket: borrowing T, inline: Bool) throws {
        while true {
            let (buffer, read):(InlineArray<1024, UInt8>, Int) = try socket.readBuffer()
            if read <= 0 {
                break
            }
            print("loadRequestLine;read=\(read)")
            // 32 = SPACE
            // 13 = \r
            // 10 = \n

            let startLine = try HTTPStartLine(buffer: buffer)
            print("startLine=\(startLine)")

            var skip:UInt8 = 0
            let nextLine:InlineArray<256, UInt8> = .init(repeating: 0)
            let _:InlineArray<256, UInt8>? = buffer.split(
                separators: 13, 10,
                defaultValue: 0,
                offset: startLine.endIndex + 1,
                yield: { slice in
                    if skip == 2 { // content
                    } else if slice == nextLine {
                        skip += 1
                    } else { // header
                    }
                    print("slice=\(slice.string())")
                }
            )
            if read < 1024 {
                break
            }
        }
        //loadRequestLine;read=512
        //slice=Host: 192.168.1.174:8080
        //slice=Connection: keep-alive
        //slice=Pragma: no-cache
        //slice=Cache-Control: no-cache
        //slice=Upgrade-Insecure-Requests: 1
        //slice=User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36
        //slice=Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        //slice=Accept-Encoding: gzip, deflate
        //slice=Accept-Language: en-US,en;q=0.9
        //slice=Cookie: cookie1=yessir; cookie2=pogchamp

        return nil // TODO: finish
        /*guard let request = ConcreteRequest.init(tokens: test) else {
            throw SocketError.malformedRequest()
        }
        return request*/
    }
}