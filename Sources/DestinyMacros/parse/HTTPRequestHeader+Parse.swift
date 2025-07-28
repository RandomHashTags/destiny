
import DestinyBlueprint
import DestinyDefaults
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPRequestHeader {
    public init?(expr: ExprSyntaxProtocol) {
        guard let string = expr.memberAccess?.declName.baseName.text else { return nil }
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
        _ expr: ExprSyntax
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
        _ expr: ExprSyntax
    ) -> String? {
        guard let key = expr.stringLiteral?.string else { return nil }
        guard !key.contains(" ") else {
            context.diagnose(Diagnostic(node: expr, message: DiagnosticMsg(id: "spacesNotAllowedInHTTPFieldName", message: "Spaces aren't allowed in HTTP field names.")))
            return nil
        }
        return key
    }
}