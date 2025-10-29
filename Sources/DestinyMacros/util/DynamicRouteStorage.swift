
import DestinyBlueprint
import SwiftSyntax

struct DynamicRouteStorage {
    var caseInsensitiveRoutes:[(DynamicRoute, FunctionCallExprSyntax)] = []
    var caseSensitiveRoutes:[(DynamicRoute, FunctionCallExprSyntax)] = []
}

// MARK: Remove
extension DynamicRouteStorage {
    /// Removes a route matching the given parameters.
    mutating func remove(isCaseSensitive: Bool, path: [PathComponent], function: FunctionCallExprSyntax) {
        if isCaseSensitive {
            if let index = caseSensitiveRoutes.firstIndex(where: { $0.0.path == path && $0.1 == function }) {
                caseSensitiveRoutes.remove(at: index)
            }
        } else {
            if let index = caseInsensitiveRoutes.firstIndex(where: { $0.0.path == path && $0.1 == function }) {
                caseInsensitiveRoutes.remove(at: index)
            }
        }
    }
}