
public struct HTTPCookieError: DestinyErrorProtocol {
    public let identifier:String
    public let reason:String

    public init(identifier: String, reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

extension HTTPCookieError {
    #if Inlinable
    @inlinable
    #endif
    public static func illegalCharacter(value: String, illegalChar: Character) -> HTTPCookieError {
        .init(identifier: "illegalCharacter", reason: "Cookie value (\"\(value)\") contains an illegal character (\"\(illegalChar)\" aka \(illegalChar.asciiValue ?? 0))")
    }
}