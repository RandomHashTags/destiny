
struct LiteralRouteResponder: Sendable {
    let vary:[IntermediateHTTPMessage.Vary:String]
    let string:String
}