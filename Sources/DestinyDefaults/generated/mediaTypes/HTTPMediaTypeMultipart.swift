
import DestinyBlueprint

public enum HTTPMediaTypeMultipart: String, HTTPMediaTypeProtocol {
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
        case .alternative: rawValue
        case .appledouble: rawValue
        case .byteranges: rawValue
        case .digest: rawValue
        case .encrypted: rawValue
        case .example: rawValue
        case .formData: "form-data"
        case .headerSet: "header-set"
        case .mixed: rawValue
        case .multilingual: rawValue
        case .parallel: rawValue
        case .related: rawValue
        case .report: rawValue
        case .signed: rawValue
        case .medPlus: "vnd.bint.med-plus"
        case .voiceMessage: "voice-message"
        case .xMixedReplace: "x-mixed-replace"
        }
    }
}