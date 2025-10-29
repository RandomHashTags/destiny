
import SwiftSyntax

struct StaticRouteStorage {
    var caseInsensitiveRoutes:[(StaticRoute, FunctionCallExprSyntax)] = []
    var caseSensitiveRoutes:[(StaticRoute, FunctionCallExprSyntax)] = []
}

// MARK: Remove
extension StaticRouteStorage {
    /// Removes a route matching the given parameters.
    mutating func remove(isCaseSensitive: Bool, path: [String], function: FunctionCallExprSyntax) {
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