
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