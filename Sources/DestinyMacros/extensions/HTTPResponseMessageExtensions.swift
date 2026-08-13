
import Destiny

// MARK: HTTPResponseMessage
extension HTTPResponseMessage {
    public func headString(
        escapeLineBreak: Bool,
        contentLength: Int
    ) -> String {
        let suffix = escapeLineBreak ? "\\r\\n" : "\r\n"
        var string = head.string(suffix: suffix)
        if let body {
            if let contentType {
                string += "content-type: \(contentType)\((charset != nil ? "; charset=\(charset!.rawName)" : ""))\(suffix)"
            }
            if body.hasContentLength {
                string += "content-length: \(contentLength)\(suffix)\(suffix)"
            }
        } else {
            string += suffix
        }
        return string
    }
}