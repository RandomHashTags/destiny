
#if RouterSettings

import Destiny
import SwiftSyntax

extension RouterSettings {
    var requestTypeSyntax: TypeSyntax {
        TypeSyntax("inout HTTPRequest")
    }
}

#endif