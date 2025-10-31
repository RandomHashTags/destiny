
import Destiny

// MARK: HTTPResponseMessage
extension HTTPResponseMessage {
    public func intermediateString(escapeLineBreak: Bool) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string = head.string(suffix: suffix)
        if let body {
            if let contentType {
                string += "content-type: \(contentType)\((charset != nil ? "; charset=\(charset!.rawName)" : ""))\(suffix)"
            }
            if body.hasContentLength {
                string += "content-length: \(body.count)\(suffix)\(suffix)"
            }
        }
        return string
    }
}