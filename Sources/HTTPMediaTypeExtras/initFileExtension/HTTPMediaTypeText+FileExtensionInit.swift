
import HTTPMediaTypes

extension HTTPMediaTypeText {
    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        case "ics": self = .calendar
        case "csv": self = .csv
        case "html": self = .html
        case "js": self = .javascript
        case "md", "markdown": self = .markdown
        case "n3": self = .n3
        case "txt": self = .plain
        case "xml": self = .xml
        default: return nil
        }
    }
}