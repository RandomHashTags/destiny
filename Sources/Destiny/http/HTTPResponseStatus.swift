
// MARK: HTTPResponseStatus
/// HTTP Status Codes. 
/// 
/// Useful links:
/// - Standard Registry: https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
/// - Wikipedia: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
public enum HTTPResponseStatus {
    public typealias Code = UInt16
}

// MARK: Storage
extension HTTPResponseStatus {
    public protocol StorageProtocol: Sendable {
        /// Status code of the HTTP Response Status.
        var code: HTTPResponseStatus.Code { get }

        /// Category that the status code falls under.
        var category: HTTPResponseStatus.Category { get }
    }
}

extension HTTPResponseStatus.StorageProtocol {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }

    public var category: HTTPResponseStatus.Category {
        switch code {
        case 100...199: .informational
        case 200...299: .successful
        case 300...399: .redirection
        case 400...499: .clientError
        case 500...599: .serverError
        default:        .nonStandard
        }
    }
}

// MARK: Category
extension HTTPResponseStatus {
    /// Category of the HTTP Response Status.
    public enum Category {
        /// Status codes that are 1xx; request received, continuing process.
        case informational
        
        /// Status codes that are 2xx; action was successfully received, understood and accepted.
        case successful

        /// Status codes that are 3xx; further action must be taken in order to complete the request.
        case redirection

        /// Status codes that are 4xx; request contains bad syntax or cannot be fulfilled.
        case clientError

        /// Status codes that are 5xx; server failed to fulfill an apparently valid request.
        case serverError

        /// Status codes not officially recognized by the HTTP standard (any status code not 1xx, 2xx, 3xx, 4xx, or 5xx).
        case nonStandard
    }
}