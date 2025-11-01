
#if PercentEncoding

/// https://en.wikipedia.org/wiki/Percent-encoding
public enum PercentEncoding {
    public static let hexDigits:[16 of Character] = [
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "A",
        "B",
        "C",
        "D",
        "E",
        "F"
    ]

    public static let unreserved:Set<UInt8> = [
        .A, .a,
        .B, .b,
        .C, .c,
        .D, .d,
        .E, .e,
        .F, .f,
        .G, .g,
        .H, .h,
        .I, .i,
        .J, .j,
        .K, .k,
        .L, .l,
        .M, .m,
        .N, .n,
        .O, .o,
        .P, .p,
        .Q, .q,
        .R, .r,
        .S, .s,
        .T, .t,
        .U, .u,
        .V, .v,
        .W, .w,
        .X, .x,
        .Y, .y,
        .Z, .z,
        .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine,
        .subtract, .underscore, .tilde, .period
    ]

    public static let uriReservedMap:[UInt8:String] = [
        .space: "%20",
        .exclamationMark: "%21",
        .numberSign: "%23",
        .dollarSign: "%24",
        .percent: "%25",
        .ampersand: "%26",
        .apostrophe: "%27",
        .openingParenthesis: "%28",
        .closingParenthesis: "%29",
        .asterisk: "%2A",
        .plus: "%2B",
        .comma: "%2C",
        .forwardSlash: "%2F",
        .colon: "%3A",
        .semicolon: "%3B",
        .equal: "%3D",
        .questionMark: "%3F",
        .atSign: "%40",
        .openingBracket: "%5B",
        .closingBracket: "%5D"
    ]

    public static let commonMap:[UInt8:String] = [
        .quotation: "%22",
        .subtract: "%2D",
        .period: "%2E",
        .lessThan: "%3C",
        .greaterThan: "%3E",
        .backslash: "%5C",
        .caret: "%5E",
        .underscore: "%5F",
        .graveAccent: "%60",
        .openingBrace: "%7B",
        .verticalBar: "%7C",
        .closingBrace: "%7D",
        .tilde: "%7E",
        .poundSign: "%C2%A3",
        .euroSign: "%E2%82%AC"
    ]

    public static let cookieMap:[UInt8:String] = [
        .space: "%20",
        .quotation: "%22",
        .comma: "%2C",
        .semicolon: "%3B",
        .equal: "%3D",
        .backslash: "%5C"
    ]

    @inlinable
    @inline(__always)
    public static func byteToHex(_ byte: UInt8) -> (high: Character, low: Character) {
        let high = PercentEncoding.hexDigits[unchecked: Int(byte >> 4)]
        let low = PercentEncoding.hexDigits[unchecked: Int(byte & 0x0F)]
        return (high, low)
    }
}

// MARK: URL
extension String {
    /// Encodes `self` using url percent encoding.
    /// 
    /// - Complexity: O(_n_).
    public func urlPercentEncoded() -> String {
        let percent = Character("%")
        var string = ""
        string.reserveCapacity(utf8Span.count)
        var i = startIndex
        while i < endIndex {
            let char = self[i]
            if let ascii = char.asciiValue {
                if let encodedValue = PercentEncoding.uriReservedMap[ascii] {
                    string.append(encodedValue)
                } else if PercentEncoding.unreserved.contains(ascii) {
                    string.append(char)
                } else {
                    let (high, low) = PercentEncoding.byteToHex(ascii)
                    string.append(percent)
                    string.append(high)
                    string.append(low)
                }
            } else {
                // TODO: fix?
            }
            formIndex(after: &i)
        }
        return string
    }
}

#if HTTPCookie
// MARK: Cookie
extension String {
    /// Encodes `self` as an HTTP Cookie Value (percent encoded).
    /// 
    /// - Complexity: O(_n_).
    public func httpCookiePercentEncoded() -> String {
        let percent = Character("%")
        var string = ""
        let span = utf8Span.span
        string.reserveCapacity(span.count)
        for i in span.indices {
            let byte = span[unchecked: i]
            if HTTPCookie.isValidInValue(byte) {
                string.append(Character(UnicodeScalar(byte)))
            } else {
                let (high, low) = PercentEncoding.byteToHex(byte)
                string.append(percent)
                string.append(high)
                string.append(low)
            }
        }
        return string
    }
}
#endif

#endif