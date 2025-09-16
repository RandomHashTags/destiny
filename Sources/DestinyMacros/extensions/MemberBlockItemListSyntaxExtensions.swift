
import SwiftSyntax

extension MemberBlockItemListSyntax {
    mutating func append(_ decl: some DeclSyntaxProtocol) {
        self.append(.init(decl: decl))
    }
}