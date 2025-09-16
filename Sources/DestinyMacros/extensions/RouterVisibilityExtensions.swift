
import DestinyBlueprint
import SwiftSyntax

extension RouterVisibility {
    var modifierDecl: DeclModifierSyntax {
        switch self {
        case .public: .init(name: .keyword(.public))
        case .package: .init(name: .keyword(.package))
        case .internal: .init(name: .keyword(.internal))
        case .fileprivate: .init(name: .keyword(.fileprivate))
        case .private: .init(name: .keyword(.private))
        }
    }
}