
#if RouterSettings

import DestinyBlueprint
import SwiftSyntax

extension RouterSettings {
    var requestTypeSyntax: TypeSyntax {
        TypeSyntax(stringLiteral: "inout HTTPRequest")
    }
}

#endif