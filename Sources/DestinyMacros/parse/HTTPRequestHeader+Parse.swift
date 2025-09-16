
import DestinyBlueprint
import DestinyDefaults
import HTTPHeaderExtras
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPStandardRequestHeader {
    public init?(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) {
        guard let string = expr.memberAccess?.declName.baseName.text else {
            context.diagnose(DiagnosticMsg.expectedMemberAccessExpr(expr: expr))
            return nil
        }
        if let value = Self(rawValue: string) {
            self = value
        } else {
            return nil
        }
    }
}
extension HTTPNonStandardRequestHeader {
    public init?(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) {
        guard let string = expr.memberAccess?.declName.baseName.text else {
            context.diagnose(DiagnosticMsg.expectedMemberAccessExpr(expr: expr))
            return nil
        }
        if let value = Self(rawValue: string) {
            self = value
        } else {
            return nil
        }
    }
}

extension HTTPRequestHeader {
    /// - Returns: The valid headers in a dictionary.
    public static func parse(
        context: some MacroExpansionContext,
        _ expr: some ExprSyntaxProtocol
    ) -> HTTPHeaders {
        guard let dictionary:[(String, String)] = expr.dictionary?.content.as(DictionaryElementListSyntax.self)?.compactMap({
            guard let key = HTTPRequestHeader.parse(context: context, $0.key) else { return nil }
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
}

extension HTTPRequestHeader {
    public static func parse(
        context: some MacroExpansionContext,
        _ expr: some ExprSyntaxProtocol
    ) -> String? {
        guard let key = expr.stringLiteralString(context: context) else { return nil }
        guard !key.contains(" ") else {
            context.diagnose(.init(node: expr, message: DiagnosticMsg(id: "spacesNotAllowedInHTTPFieldName", message: "Spaces aren't allowed in HTTP field names.")))
            return nil
        }
        return key
    }
}