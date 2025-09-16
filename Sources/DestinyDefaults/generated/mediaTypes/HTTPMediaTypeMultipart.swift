
import DestinyBlueprint

public enum HTTPMediaTypeMultipart: HTTPMediaTypeProtocol {
    case alternative
    case appledouble
    case byteranges
    case digest
    case encrypted
    case example
    case formData
    case headerSet
    case mixed
    case multilingual
    case parallel
    case related
    case report
    case signed
    case medPlus
    case voiceMessage
    case xMixedReplace

    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {

        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var type: String {
        "multipart"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case .alternative: "alternative"
        case .appledouble: "appledouble"
        case .byteranges: "byteranges"
        case .digest: "digest"
        case .encrypted: "encrypted"
        case .example: "example"
        case .formData: "form-data"
        case .headerSet: "header-set"
        case .mixed: "mixed"
        case .multilingual: "multilingual"
        case .parallel: "parallel"
        case .related: "related"
        case .report: "report"
        case .signed: "signed"
        case .medPlus: "vnd.bint.med-plus"
        case .voiceMessage: "voice-message"
        case .xMixedReplace: "x-mixed-replace"
        }
    }
}