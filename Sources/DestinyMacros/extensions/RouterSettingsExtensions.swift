
#if RouterSettings

import Destiny
import SwiftSyntax

extension RouterSettings {
    var requestTypeSyntax: TypeSyntax {
        TypeSyntax(stringLiteral: "inout HTTPRequest")
    }
}

#endif