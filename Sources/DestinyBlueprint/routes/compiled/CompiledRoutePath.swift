
public struct CompiledRoutePath<each Component: RoutePathComponentProtocol>: Equatable, Sendable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for (left, right) in repeat (each lhs.components, each rhs.components) {
            guard left == right else { return false }
        }
        return true
    }

    @usableFromInline
    let components:(repeat each Component)

    public init(_ components: (repeat each Component)) {
        self.components = components
    }
}