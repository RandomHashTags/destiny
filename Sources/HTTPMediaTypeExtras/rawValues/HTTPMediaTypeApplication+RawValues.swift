
import HTTPMediaTypes

extension HTTPMediaTypeApplication: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "calendarJSON": self = .calendarJSON
        case "calendarXML": self = .calendarXML
        case "dns": self = .dns
        case "dnsJSON": self = .dnsJSON
        case "dnsMessage": self = .dnsMessage
        case "example": self = .example
        case "excel": self = .excel
        case "geoJSON": self = .geoJSON
        case "geoJSONSeq": self = .geoJSONSeq
        case "gzip": self = .gzip
        case "http": self = .http
        case "index": self = .index
        case "json": self = .json
        case "jsonPatchJSON": self = .jsonPatchJSON
        case "jsonSeq": self = .jsonSeq
        case "jsonpath": self = .jsonpath
        case "jwkJSON": self = .jwkJSON
        case "jwkSetJSON": self = .jwkSetJSON
        case "jwkSetJWT": self = .jwkSetJWT
        case "jwt": self = .jwt
        case "ldJSON": self = .ldJSON
        case "manifestJSON": self = .manifestJSON
        case "mp4": self = .mp4
        case "msword": self = .msword
        case "nasdata": self = .nasdata
        case "node": self = .node
        case "nss": self = .nss
        case "ogg": self = .ogg
        case "pdf": self = .pdf
        case "pdx": self = .pdx
        case "pemCertificateChain": self = .pemCertificateChain
        case "pgpEncrypted": self = .pgpEncrypted
        case "pgpKeys": self = .pgpKeys
        case "pgpSignature": self = .pgpSignature
        case "portableExecutable": self = .portableExecutable
        case "powerpoint": self = .powerpoint
        case "rtf": self = .rtf
        case "rtploopback": self = .rtploopback
        case "rtx": self = .rtx
        case "sql": self = .sql
        case "vc": self = .vc
        case "adobeFlashMovie": self = .adobeFlashMovie
        case "appleInstallerXML": self = .appleInstallerXML
        case "appleKeynote": self = .appleKeynote
        case "appleMpegURL": self = .appleMpegURL
        case "appleNumbers": self = .appleNumbers
        case "applePages": self = .applePages
        case "chessPGN": self = .chessPGN
        case "curl": self = .curl
        case "dart": self = .dart
        case "dna": self = .dna
        case "herokuJSON": self = .herokuJSON
        case "kahootz": self = .kahootz
        case "rar": self = .rar
        case "wasm": self = .wasm
        case "xwwwFormURLEncoded": self = .xwwwFormURLEncoded
        case "xx509CACert": self = .xx509CACert
        case "xx509CARACert": self = .xx509CARACert
        case "xx509NextCACert": self = .xx509NextCACert
        case "xml": self = .xml
        case "xGoogleProtobuf": self = .xGoogleProtobuf
        case "xProtobuf": self = .xProtobuf
        case "yaml": self = .yaml
        case "yang": self = .yang
        case "zip": self = .zip
        case "zlib": self = .zlib
        case "zstd": self = .zstd
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case .calendarJSON: "calendarJSON"
        case .calendarXML: "calendarXML"
        case .dns: "dns"
        case .dnsJSON: "dnsJSON"
        case .dnsMessage: "dnsMessage"
        case .example: "example"
        case .excel: "excel"
        case .geoJSON: "geoJSON"
        case .geoJSONSeq: "geoJSONSeq"
        case .gzip: "gzip"
        case .http: "http"
        case .index: "index"
        case .json: "json"
        case .jsonPatchJSON: "jsonPatchJSON"
        case .jsonSeq: "jsonSeq"
        case .jsonpath: "jsonpath"
        case .jwkJSON: "jwkJSON"
        case .jwkSetJSON: "jwkSetJSON"
        case .jwkSetJWT: "jwkSetJWT"
        case .jwt: "jwt"
        case .ldJSON: "ldJSON"
        case .manifestJSON: "manifestJSON"
        case .mp4: "mp4"
        case .msword: "msword"
        case .nasdata: "nasdata"
        case .node: "node"
        case .nss: "nss"
        case .ogg: "ogg"
        case .pdf: "pdf"
        case .pdx: "pdx"
        case .pemCertificateChain: "pemCertificateChain"
        case .pgpEncrypted: "pgpEncrypted"
        case .pgpKeys: "pgpKeys"
        case .pgpSignature: "pgpSignature"
        case .portableExecutable: "portableExecutable"
        case .powerpoint: "powerpoint"
        case .rtf: "rtf"
        case .rtploopback: "rtploopback"
        case .rtx: "rtx"
        case .sql: "sql"
        case .vc: "vc"
        case .adobeFlashMovie: "adobeFlashMovie"
        case .appleInstallerXML: "appleInstallerXML"
        case .appleKeynote: "appleKeynote"
        case .appleMpegURL: "appleMpegURL"
        case .appleNumbers: "appleNumbers"
        case .applePages: "applePages"
        case .chessPGN: "chessPGN"
        case .curl: "curl"
        case .dart: "dart"
        case .dna: "dna"
        case .herokuJSON: "herokuJSON"
        case .kahootz: "kahootz"
        case .rar: "rar"
        case .wasm: "wasm"
        case .xwwwFormURLEncoded: "xwwwFormURLEncoded"
        case .xx509CACert: "xx509CACert"
        case .xx509CARACert: "xx509CARACert"
        case .xx509NextCACert: "xx509NextCACert"
        case .xml: "xml"
        case .xGoogleProtobuf: "xGoogleProtobuf"
        case .xProtobuf: "xProtobuf"
        case .yaml: "yaml"
        case .yang: "yang"
        case .zip: "zip"
        case .zlib: "zlib"
        case .zstd: "zstd"
        }
    }
}