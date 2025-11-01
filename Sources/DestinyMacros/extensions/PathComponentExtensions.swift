
import Destiny

// MARK: CustomDebugStringConvertible
extension PathComponent: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .literal(let s): "PathComponent.literal(\"\(s)\")"
        case .parameter(let s): "PathComponent.parameter(parameterName: \"\(s)\")"
        case .catchall: "PathComponent.catchall"
        case .components(let l, let r): "PathComponent.components(\(l.debugDescription), \(r?.debugDescription ?? "nil"))"
        }
    }
}