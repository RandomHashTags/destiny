
import HTTPMediaTypes

extension HTTPMediaTypeMultipart: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "alternative": self = .alternative
        case "appledouble": self = .appledouble
        case "byteranges": self = .byteranges
        case "digest": self = .digest
        case "encrypted": self = .encrypted
        case "example": self = .example
        case "formData": self = .formData
        case "headerSet": self = .headerSet
        case "mixed": self = .mixed
        case "multilingual": self = .multilingual
        case "parallel": self = .parallel
        case "related": self = .related
        case "report": self = .report
        case "signed": self = .signed
        case "medPlus": self = .medPlus
        case "voiceMessage": self = .voiceMessage
        case "xMixedReplace": self = .xMixedReplace
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case .alternative: "alternative"
        case .appledouble: "appledouble"
        case .byteranges: "byteranges"
        case .digest: "digest"
        case .encrypted: "encrypted"
        case .example: "example"
        case .formData: "formData"
        case .headerSet: "headerSet"
        case .mixed: "mixed"
        case .multilingual: "multilingual"
        case .parallel: "parallel"
        case .related: "related"
        case .report: "report"
        case .signed: "signed"
        case .medPlus: "medPlus"
        case .voiceMessage: "voiceMessage"
        case .xMixedReplace: "xMixedReplace"
        }
    }
}