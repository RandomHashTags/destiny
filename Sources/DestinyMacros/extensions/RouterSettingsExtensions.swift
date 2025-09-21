
import DestinyBlueprint
import SwiftSyntax

extension RouterSettings {
    var requestTypeSyntax: TypeSyntax {
        hasProtocolConformances ? TypeSyntax("inout some HTTPRequestProtocol & ~Copyable") : TypeSyntax(stringLiteral: "inout \(requestType)")
    }
}