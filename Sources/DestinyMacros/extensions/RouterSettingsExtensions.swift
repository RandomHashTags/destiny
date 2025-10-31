
#if RouterSettings

import SwiftSyntax

extension RouterSettings {
    var requestTypeSyntax: TypeSyntax {
        TypeSyntax(stringLiteral: "inout HTTPRequest")
    }
}

#endif