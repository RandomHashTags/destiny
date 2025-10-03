
#if PercentEncoding

/// https://en.wikipedia.org/wiki/Percent-encoding
public enum PercentEncoding {
    public static let unreserved:Set<Character> = [
        "A", "a",
        "B", "b",
        "C", "c",
        "D", "d",
        "E", "e",
        "F", "f",
        "G", "g",
        "H", "h",
        "I", "i",
        "J", "j",
        "K", "k",
        "L", "l",
        "M", "m",
        "N", "n",
        "O", "o",
        "P", "p",
        "Q", "q",
        "R", "r",
        "S", "s",
        "T", "t",
        "U", "u",
        "V", "v",
        "W", "w",
        "X", "x",
        "Y", "y",
        "Z", "z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "-", "_", "~", "."
    ]

    public static let uriReservedMap:[Character:String] = [
        " ": "%20",
        "!": "%21",
        "#": "%23",
        "$": "%24",
        "%": "%25",
        "&": "%26",
        "'": "%27",
        "(": "%28",
        ")": "%29",
        "*": "%2A",
        "+": "%2B",
        ",": "%2C",
        "/": "%2F",
        ":": "%3A",
        ";": "%3B",
        "=": "%3D",
        "?": "%3F",
        "@": "%40",
        "[": "%5B",
        "]": "%5D"
    ]

    public static let commonMap:[Character:String] = [
        "\"": "%22",
        "-": "%2D",
        ".": "%2E",
        "<": "%3C",
        ">": "%3E",
        "\\": "%5C",
        "^": "%5E",
        "_": "%5F",
        "`": "%60",
        "{": "%7B",
        "|": "%7C",
        "}": "%7D",
        "~": "%7E",
        "£": "%C2%A3",
        "€": "%E2%82%AC"
    ]

    public static let cookieMap:[Character:String] = [
        " ": "%20",
        "\"": "%22",
        ",": "%2C",
        ";": "%3B",
        "=": "%3D",
        "\\": "%5C"
    ]
}

// MARK: URL
extension String {
    /// - Complexity: O(_n_).
    #if Inlinable
    @inlinable
    #endif
    public func urlPercentEncoded() -> String {
        var string = ""
        string.reserveCapacity(utf8Span.count)
        var i = startIndex
        while i < endIndex {
            let char = self[i]
            if let encodedValue = PercentEncoding.uriReservedMap[char] {
                string.append(encodedValue)
            } else if PercentEncoding.unreserved.contains(char) {
                string.append(char)
            }
            formIndex(after: &i)
        }
        return string
    }
}

// MARK: Cookie
extension String {
    /// - Complexity: O(_n_).
    #if Inlinable
    @inlinable
    #endif
    public func httpCookiePercentEncoded() -> String {
        var string = ""
        string.reserveCapacity(utf8Span.count)
        var i = startIndex
        while i < endIndex {
            let char = self[i]
            if let encodedValue = PercentEncoding.cookieMap[char] {
                string.append(encodedValue)
            } else if PercentEncoding.unreserved.contains(char) {
                string.append(char)
            }
            formIndex(after: &i)
        }
        return string
    }
}

#endif