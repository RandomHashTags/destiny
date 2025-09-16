
import DestinyBlueprint

public enum HTTPMediaTypeApplication: HTTPMediaTypeProtocol {
    case calendarJSON
    case calendarXML
    case dns
    case dnsJSON
    case dnsMessage
    case example
    case excel
    case geoJSON
    case geoJSONSeq
    case gzip
    case http
    case index
    case json
    case jsonPatchJSON
    case jsonSeq
    case jsonpath
    case jwkJSON
    case jwkSetJSON
    case jwkSetJWT
    case jwt
    case ldJSON
    case manifestJSON
    case mp4
    case msword
    case nasdata
    case node
    case nss
    case ogg
    case pdf
    case pdx
    case pemCertificateChain
    case pgpEncrypted
    case pgpKeys
    case pgpSignature
    case portableExecutable
    case powerpoint
    case rtf
    case rtploopback
    case rtx
    case sql
    case vc
    case adobeFlashMovie
    case appleInstallerXML
    case appleKeynote
    case appleMpegURL
    case appleNumbers
    case applePages
    case chessPGN
    case curl
    case dart
    case dna
    case herokuJSON
    case kahootz
    case rar
    case wasm
    case xwwwFormURLEncoded
    case xx509CACert
    case xx509CARACert
    case xx509NextCACert
    case xml
    case xGoogleProtobuf
    case xProtobuf
    case yaml
    case yang
    case zip
    case zlib
    case zstd

    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        case "geojson": self = .geoJSON
        case "gz": self = .gzip
        case "json": self = .json
        case "json-patch": self = .jsonPatchJSON
        case "jsonld": self = .ldJSON
        case "mp4": self = .mp4
        case "pdf": self = .pdf
        case "rtf": self = .rtf
        case "sql": self = .sql
        case "vc": self = .vc
        case "swf": self = .adobeFlashMovie
        case "dist", "distz", "pkg", "mpkg": self = .appleInstallerXML
        case "key": self = .appleKeynote
        case "m3u8", "m3u": self = .appleMpegURL
        case "numbers": self = .appleNumbers
        case "pages": self = .applePages
        case "pgn": self = .chessPGN
        case "dna": self = .dna
        case "rar": self = .rar
        case "wasm": self = .wasm
        case "xml": self = .xml
        case "yaml", "yml": self = .yaml
        case "yang": self = .yang
        case "zip": self = .zip
        case "zst": self = .zstd
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var type: String {
        "application"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case .calendarJSON: "calendar+json"
        case .calendarXML: "calendar+xml"
        case .dns: "dns"
        case .dnsJSON: "dns+json"
        case .dnsMessage: "dns-message"
        case .example: "example"
        case .excel: "vnd.ms-excel"
        case .geoJSON: "geo+json"
        case .geoJSONSeq: "geo+json-seq"
        case .gzip: "gzip"
        case .http: "http"
        case .index: "index"
        case .json: "json"
        case .jsonPatchJSON: "json-patch+json"
        case .jsonSeq: "json-seq"
        case .jsonpath: "jsonpath"
        case .jwkJSON: "jwk+json"
        case .jwkSetJSON: "jwk-set+json"
        case .jwkSetJWT: "jwk-set+jwt"
        case .jwt: "jwt"
        case .ldJSON: "ld+json"
        case .manifestJSON: "manifest+json"
        case .mp4: "mp4"
        case .msword: "msword"
        case .nasdata: "nasdata"
        case .node: "node"
        case .nss: "nss"
        case .ogg: "ogg"
        case .pdf: "pdf"
        case .pdx: "PDX"
        case .pemCertificateChain: "pem-certificate-chain"
        case .pgpEncrypted: "php-encrypted"
        case .pgpKeys: "pgp-keys"
        case .pgpSignature: "pgp-signature"
        case .portableExecutable: "vnd.microsoft.portable-executable"
        case .powerpoint: "vnd.ms-powerpoint"
        case .rtf: "rtf"
        case .rtploopback: "rtploopback"
        case .rtx: "rtx"
        case .sql: "sql"
        case .vc: "vc"
        case .adobeFlashMovie: "vnd.adobe.flash.movie"
        case .appleInstallerXML: "vnd.apple.installer+xml"
        case .appleKeynote: "vnd.apple.keynote"
        case .appleMpegURL: "vnd.apple.mpegurl"
        case .appleNumbers: "vnd.apple.numbers"
        case .applePages: "vnd.apple.pages"
        case .chessPGN: "vnd.chess-pgn"
        case .curl: "vnd.curl"
        case .dart: "vnd.dart"
        case .dna: "vnd.dna"
        case .herokuJSON: "vnd.heroku+json"
        case .kahootz: "vnd.kahootz"
        case .rar: "vnd.rar"
        case .wasm: "wasm"
        case .xwwwFormURLEncoded: "x-www-form-urlencoded"
        case .xx509CACert: "x-x509-ca-cert"
        case .xx509CARACert: "x-x509-ca-ra-cert"
        case .xx509NextCACert: "x-x509-next-ca-cert"
        case .xml: "xml"
        case .xGoogleProtobuf: "x-google-protobuf"
        case .xProtobuf: "x-protobuf"
        case .yaml: "yaml"
        case .yang: "yang"
        case .zip: "zip"
        case .zlib: "zlib"
        case .zstd: "zstd"
        }
    }
}