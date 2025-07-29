
// MARK: HTTPMediaTypeProtocol
public protocol HTTPMediaTypeProtocol: CustomStringConvertible, Sendable {
    var type: String { get }
    var subType: String { get }
}