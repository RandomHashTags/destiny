
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

// MARK: RawRepresentable
extension RouterVisibility: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        switch rawValue {
        case "public": self = .public
        case "package": self = .package
        case "internal": self = .internal
        case "fileprivate": self = .fileprivate
        case "private": self = .private
        default: return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .public: "public"
        case .package: "package"
        case .internal: "internal"
        case .fileprivate: "fileprivate"
        case .private: "private"
        }
    }
}

// MARK: CustomStringConvertible
extension RouterVisibility: CustomStringConvertible {
    public var description: String {
        switch self {
        case .internal: ""
        default: "\(rawValue) "
        }
    }
}