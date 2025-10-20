
#if HTTPCookie

import DestinyBlueprint
import DestinyDefaults
import Testing

@Suite
struct HTTPCookieTests {
    static let illegals:Set<Character> = {
        var illegals:Set<Character> = Set((0..<32).map({ Character(UnicodeScalar($0)) }))
        illegals.formUnion((128...255).map({ Character(UnicodeScalar($0)) }))
        illegals.insert(Character(UnicodeScalar(127)))
        illegals.insert(",")
        illegals.insert(";")
        illegals.insert("\"")
        illegals.insert("\\")
        illegals.insert(" ")
        return illegals
    }()

    @Test
    func httpCookieIllegalValue() {
        for illegal in Self.illegals {
            let illegalValue = "its-cr1tter-season\(illegal)"
            #expect(throws: HTTPCookieError.illegalCharacter(illegal)) {
                let _ = try HTTPCookie(name: "name", value: illegalValue)
            }
        }
    }
    @Test
    func httpCookiePercentEncodeIllegalValue() throws(HTTPCookieError) {
        for illegal in Self.illegals {
            let illegalValue = "critters\(illegal); they bite".httpCookiePercentEncoded()
            let _ = try HTTPCookie(name: "name", value: illegalValue)
        }
    }

    @Test
    func httpCookieUnreservedValue() throws(HTTPCookieError) {
        for char in PercentEncoding.unreserved {
            let _ = try HTTPCookie(name: "name", value: "\(char)")
        }
    }

    @Test
    func httpCookieDescription() throws(HTTPCookieError) {
        var cookie = try HTTPCookie(name: "bro", value: "sheesh")
        #expect("\(cookie)" == "bro=sheesh")

        cookie.maxAge = 600
        #expect("\(cookie)" == "bro=sheesh; Max-Age=600")
    }

    @Test
    func httpCookieSecurePartitioned() throws(HTTPCookieError) {
        let cookie = try HTTPCookie(
            name: "a",
            value: "b",
            isSecure: true,
            isPartitioned: true
        )
        #expect("\(cookie)" == "a=b; Secure; Partitioned")
    }

    @Test
    func httpCookieInsecurePartitioned() throws(HTTPCookieError) {
        let cookie = try HTTPCookie(
            name: "a",
            value: "b",
            isSecure: false,
            isPartitioned: true
        )
        #expect("\(cookie)" == "a=b")
    }

    @Test
    func httpCookieAllFlags() throws(HTTPCookieError) {
        let cookie = try HTTPCookie(
            name: "all",
            value: "flags",
            maxAge: .max,
            expires: "anything",
            domain: "litleagues.com",
            path: "/",
            isSecure: true,
            isPartitioned: true,
            isHTTPOnly: true,
            sameSite: .strict
        )
        let expected = "all=flags; Max-Age=\(UInt64.max); Expires=anything; Secure; Partitioned; HttpOnly; Domain=litleagues.com; Path=/; SameSite=Strict"
        #expect("\(cookie)" == expected)
    }
}

extension HTTPCookieError: Equatable {
    public static func == (lhs: HTTPCookieError, rhs: HTTPCookieError) -> Bool {
        switch lhs {
        case .illegalCharacter(let c):
            guard case let .illegalCharacter(cc) = rhs else { return false }
            return c == cc
        default:
            return false
        }
    }
}

#endif