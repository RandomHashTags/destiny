
import Destiny

public struct IntermediateHTTPMessage: Sendable {
    var head:HTTPResponseMessageHead
    var body:IntermediateResponseBody?
    var contentType:String?
    var charset:Charset?
    var vary = Set<Vary>()
}

extension IntermediateHTTPMessage {
    enum Vary: Sendable {
        case acceptEncoding
    }
}