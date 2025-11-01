
import Destiny
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

#if HTTPStandardRequestHeaders

extension HTTPStandardRequestHeader {
    public init?(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) {
        guard let string = expr.memberAccess?.declName.baseName.text else {
            context.diagnose(DiagnosticMsg.expectedMemberAccessExpr(expr: expr))
            return nil
        }
        #if HTTPStandardRequestHeaderRawValues
        if let value = Self(rawValue: string) {
            self = value
        }
        #endif
        return nil
    }
}

#endif

#if HTTPNonStandardRequestHeaders

extension HTTPNonStandardRequestHeader {
    public init?(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) {
        guard let string = expr.memberAccess?.declName.baseName.text else {
            context.diagnose(DiagnosticMsg.expectedMemberAccessExpr(expr: expr))
            return nil
        }
        #if HTTPNonStandardRequestHeaderRawValues
        if let value = Self(rawValue: string) {
            self = value
        }
        #endif
        return nil
    }
}

#endif

extension HTTPHeaders {
    /// - Returns: The valid headers in a dictionary.
    public static func parse(
        context: some MacroExpansionContext,
        _ expr: some ExprSyntaxProtocol
    ) -> HTTPHeaders {
        guard let dictionary:[(String, String)] = expr.dictionary?.content.as(DictionaryElementListSyntax.self)?.compactMap({
            guard let key = parse(context: context, $0.key) else { return nil }
            let value = $0.value.stringLiteral?.string ?? ""
            return (key, value)
        }) else {
            return [:]
        }
        var headers = HTTPHeaders()
        headers.reserveCapacity(dictionary.count)
        for (key, value) in dictionary {
            headers[key] = value
        }
        return headers
    }

    private static func parse(
        context: some MacroExpansionContext,
        _ expr: some ExprSyntaxProtocol
    ) -> String? {
        guard let key = expr.stringLiteralString(context: context) else { return nil }
        if let illegalByte = illegalByte(key) {
            context.diagnose(.init(node: expr, message: DiagnosticMsg(id: "illegalCharacterInHTTPFieldName", message: "Illegal character in HTTP field name: \(Character(UnicodeScalar(illegalByte))) (byte: \(illegalByte))")))
            return nil
        }
        return key
    }

    /// Spec: https://www.rfc-editor.org/rfc/rfc7230#section-3.2.6
    /// 
    /// - Returns: Byte not allowed in the field name.
    public static func illegalByte(_ key: some StringProtocol) -> UInt8? {
        guard !key.isEmpty else { return 0 }
        return key.utf8.first {
            switch $0 {
            case 33, // !
                35, // #
                36, // $
                37, // %
                38, // &
                39, // '
                42, // *
                43, // +
                45, // -
                46, // .
                48...57, // digit
                65...90, // uppercase letter
                94, // ^
                95, // _
                96, // `
                97...122,  // lowercase letter
                124, // |
                126: // ~
                return false
            default:
                return true
            }
        }
    }
}