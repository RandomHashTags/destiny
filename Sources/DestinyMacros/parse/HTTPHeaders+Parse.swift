
import DestinyBlueprint
import DestinyDefaults
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
        guard !key.contains(" ") else {
            context.diagnose(.init(node: expr, message: DiagnosticMsg(id: "spacesNotAllowedInHTTPFieldName", message: "Spaces aren't allowed in HTTP field names.")))
            return nil
        }
        return key
    }
}