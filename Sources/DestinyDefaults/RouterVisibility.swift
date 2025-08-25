
public enum RouterVisibility: String, CustomStringConvertible {
    case `public`
    case `package`
    case `internal`
    case `fileprivate`
    case `private`

    public var description: String {
        switch self {
        case .internal: ""
        default: "\(rawValue) "
        }
    }
}