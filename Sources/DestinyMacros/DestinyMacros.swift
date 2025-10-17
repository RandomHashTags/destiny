
import DestinyBlueprint
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct DestinyMacros: CompilerPlugin {
    let providingMacros:[any Macro.Type] = [
        Router.self,
        Server.self
    ]
}

var inlinableAnnotation: String {
    "@inlinable"
}
var inlineAlwaysAnnotation: String {
    "@inline(__always)"
}

func routerProtocolConformances(isCopyable: Bool, protocolConformance: Bool) -> InheritedTypeListSyntax {
    var list = InheritedTypeListSyntax()
    if isCopyable {
        if protocolConformance {
            list.append(.init(type: TypeSyntax("HTTPRouterProtocol"), trailingComma: .commaToken()))
        } else {
            list.append(.init(type: TypeSyntax("Sendable"), trailingComma: .commaToken()))
        }
        list.append(.init(type: TypeSyntax("Copyable")))
    } else {
        if protocolConformance {
            list.append(.init(type: TypeSyntax("NonCopyableHTTPRouterProtocol"), trailingComma: .commaToken()))
        }
        list.append(.init(type: TypeSyntax("~Copyable")))
    }
    return list
}

func responderCopyableValues(isCopyable: Bool) -> (symbol: String, text: String) {
    if isCopyable {
        ("", "")
    } else {
        ("~", "NonCopyable")
    }
}

func responderStorageProtocolConformances(isCopyable: Bool, protocolConformance: Bool) -> InheritedTypeListSyntax {
    var list = InheritedTypeListSyntax()
    if isCopyable {
        if protocolConformance {
            list.append(.init(type: TypeSyntax("ResponderStorageProtocol"), trailingComma: .commaToken()))
        } else {
            list.append(.init(type: TypeSyntax("Sendable"), trailingComma: .commaToken()))
        }
        list.append(.init(type: TypeSyntax("Copyable")))
    } else {
        if protocolConformance {
            list.append(.init(type: TypeSyntax("NonCopyableResponderStorageProtocol"), trailingComma: .commaToken()))
        } else {
            list.append(.init(type: TypeSyntax("Sendable"), trailingComma: .commaToken()))
        }
        list.append(.init(type: TypeSyntax("~Copyable")))
    }
    return list
}

func dynamicRouteResponderProtocolConformances(isCopyable: Bool, protocolConformance: Bool) -> InheritedTypeListSyntax {
    var list = InheritedTypeListSyntax()
    if isCopyable {
        if protocolConformance {
            list.append(.init(type: TypeSyntax("DynamicRouteResponderProtocol"), trailingComma: .commaToken()))
        } else {
            list.append(.init(type: TypeSyntax("Sendable"), trailingComma: .commaToken()))
        }
        list.append(.init(type: TypeSyntax("Copyable")))
    } else {
        if protocolConformance {
            list.append(.init(type: TypeSyntax("NonCopyableDynamicRouteResponderProtocol"), trailingComma: .commaToken()))
        } else {
            list.append(.init(type: TypeSyntax("Sendable"), trailingComma: .commaToken()))
        }
        list.append(.init(type: TypeSyntax("~Copyable")))
    }
    return list
}