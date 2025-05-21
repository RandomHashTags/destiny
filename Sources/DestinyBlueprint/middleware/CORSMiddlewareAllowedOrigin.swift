
public enum CORSMiddlewareAllowedOrigin: Sendable {
    case all
    case any(Set<String>)
    case custom(String)
    case none
    case originBased
}