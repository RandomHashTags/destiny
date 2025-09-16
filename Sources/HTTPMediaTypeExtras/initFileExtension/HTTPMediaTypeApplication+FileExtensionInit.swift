
import DestinyDefaults

extension HTTPMediaTypeApplication {
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
}