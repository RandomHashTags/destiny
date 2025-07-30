
import DestinyBlueprint
import SwiftSyntax

// MARK: SwiftSyntax
extension HTTPVersion {
    public static func parse(_ expr: some ExprSyntaxProtocol) -> HTTPVersion? {
        switch expr.as(MemberAccessExprSyntax.self)?.declName.baseName.text {
        case "v0_9": .v0_9
        case "v1_0": .v1_0
        case "v1_1": .v1_1
        case "v1_2": .v1_2
        case "v2_0": .v2_0
        case "v3_0": .v3_0
        default:     nil
        }
    }
}