//
//  HTTPFieldContentType.swift
//
//
//  Created by Evan Anderson on 10/27/24.
//

import HTTPTypes

public extension HTTPField {
    enum ContentType : Hashable, CustomStringConvertible, Sendable {
        case aac
        case abw
        case apng
        case arc
        case avif
        case avi
        case azw
        case bin
        case bmp
        case bz
        case bz2
        case cda
        case csh
        case css
        case csv
        case doc
        case docx
        case eot
        case epub
        case gz
        case gif
        case htm, html
        case ico
        case ics
        case jar
        case jpeg, jpg
        case js, javascript
        case json
        case jsonld
        case mid, midi
        case mjs
        case mp3
        case mp4
        case mpeg
        case mpkg
        case odp
        case ods
        case odt
        case oga
        case ogv
        case ogx
        case opus
        case otf
        case png
        case pdf
        case php
        case ppt
        case pptx
        case rar
        case rtf
        case sh
        case svg
        case tar
        case tif, tiff
        case ts
        case ttf
        case txt
        case vsd
        case wav
        case weba
        case webm
        case webp
        case woff
        case woff2
        case xhtml
        case xls
        case xlsx
        case xml
        case xul
        case zip
        case _3gp
        case _3g2
        case _7z
        case custom(String)

        public var description : String { rawValue }

        // MARK: init(rawValue)
        public init(rawValue: String) {
            switch rawValue {
                case "aac": self = .aac
                case "abw": self = .abw
                case "apng": self = .apng
                case "arc": self = .arc
                case "avif": self = .avif
                case "avi": self = .avi
                case "azw": self = .azw
                case "bin": self = .bin
                case "bmp": self = .bmp
                case "bz": self = .bz
                case "bz2": self = .bz2
                case "cda": self = .cda
                case "csh": self = .csh
                case "css": self = .css
                case "csv": self = .csv
                case "doc": self = .doc
                case "docx": self = .docx
                case "eot": self = .eot
                case "epub": self = .epub
                case "gz": self = .gz
                case "gif": self = .gif
                case "htm": self = .htm
                case "html": self = .html
                case "ico": self = .ico
                case "ics": self = .ics
                case "jar": self = .jar
                case "jpeg": self = .jpeg
                case "jpg": self = .jpg
                case "js": self = .js
                case "javascript": self = .javascript
                case "json": self = .json
                case "jsonld": self = .jsonld
                case "mid": self = .mid
                case "midi": self = .midi
                case "mjs": self = .mjs
                case "mp3": self = .mp3
                case "mp4": self = .mp4
                case "mpeg": self = .mpeg
                case "mpkg": self = .mpkg
                case "odp": self = .odp
                case "ods": self = .ods
                case "odt": self = .odt
                case "oga": self = .oga
                case "ogv": self = .ogv
                case "ogx": self = .ogx
                case "opus": self = .opus
                case "otf": self = .otf
                case "png": self = .png
                case "pdf": self = .pdf
                case "php": self = .php
                case "ppt": self = .ppt
                case "pptx": self = .pptx
                case "rar": self = .rar
                case "rtf": self = .rtf
                case "sh": self = .sh
                case "svg": self = .svg
                case "tar": self = .tar
                case "tif": self = .tif
                case "tiff": self = .tiff
                case "ts": self = .ts
                case "ttf": self = .ttf
                case "txt": self = .txt
                case "vsd": self = .vsd
                case "wav": self = .wav
                case "weba": self = .weba
                case "webm": self = .webm
                case "webp": self = .webp
                case "woff": self = .woff
                case "woff2": self = .woff2
                case "xhtml": self = .xhtml
                case "xls": self = .xls
                case "xlsx": self = .xlsx
                case "xml": self = .xml
                case "xul": self = .xul
                case "zip": self = .zip
                case "_3gp": self = ._3gp
                case "_3g2": self = ._3g2
                case "_7z": self = ._7z
                default: self = .custom(rawValue)
            }
        }

        // MARK: RawValue
        public var rawValue : String {
            switch self {
            case .aac: return "audio/aac"
            case .abw: return "application/x-abiword"
            case .apng: return "image/apng"
            case .arc: return "application/x-freearc"
            case .avif: return "image/avif"
            case .avi: return "video/x-msvideo"
            case .azw: return "application/vnd.amazon.ebook"
            case .bin: return "application/octet-stream"
            case .bmp: return "image/bmp"
            case .bz: return "application/x-bzip"
            case .bz2: return "application/x-bzip2"
            case .cda: return "application/x-cdf"
            case .csh: return "application/x-csh"
            case .css: return "text/css"
            case .csv: return "text/csv"
            case .doc: return "application/msword"
            case .docx: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            case .eot: return "application/vnd.ms-fontobject"
            case .epub: return "application/epub+zip"
            case .gz: return "application/gzip"
            case .gif: return "image/gif"
            case .htm, .html: return "text/html"
            case .ico: return "image/vnd.microsoft.icon"
            case .ics: return "text/calendar"
            case .jar: return "application/java-archive"
            case .jpeg, .jpg: return "image/jpeg"
            case .js, .javascript: return "text/javascript"
            case .json: return "application/json"
            case .jsonld: return "application/ld+json"
            case .mid, .midi: return "audio/midi"
            case .mjs: return "text/javascript"
            case .mp3: return "audio/mpeg"
            case .mp4: return "video/mp4"
            case .mpeg: return "video/mpeg"
            case .mpkg: return "application/vnd.apple.installer+xml"
            case .odp: return "application/vnd.oasis.opendocument.presentation"
            case .ods: return "application/vnd.oasis.opendocument.spreadsheet"
            case .odt: return "application/vnd.oasis.opendocument.text"
            case .oga: return "audio/ogg"
            case .ogv: return "video/ogg"
            case .ogx: return "application/ogg"
            case .opus: return "audio/ogg"
            case .otf: return "font/otf"
            case .png: return "image/png"
            case .pdf: return "application/pdf"
            case .php: return "application/x-httpd-php"
            case .ppt: return "application/vnd.ms-powerpoint"
            case .pptx: return "application/vnd.openxlformats-officedocument.presentationml.presentation"
            case .rar: return "application/vnd.rar"
            case .rtf: return "application/rtf"
            case .sh: return "application/x-sh"
            case .svg: return "image/svg+xml"
            case .tar: return "application/x-tar"
            case .tif, .tiff: return "image/tiff"
            case .ts: return "video/mp2t"
            case .ttf: return "font/ttf"
            case .txt: return "text/plain"
            case .vsd: return "application/vnd.visio"
            case .wav: return "audio/wav"
            case .weba: return "audio/webm"
            case .webm: return "video/webm"
            case .webp: return "image/webp"
            case .woff: return "font/woff"
            case .woff2: return "font/woff2"
            case .xhtml: return "application/xhtml+xml"
            case .xls: return "application/vnd.ms-excel"
            case .xlsx: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            case .xml: return "application/xml"
            case .xul: return "application/vnd.mozilla.xul+xml"
            case .zip: return "application/zip"
            case ._3gp: return "video/3gpp"
            case ._3g2: return "video/3gpp2"
            case ._7z: return "application/x-7z-compressed"
            case .custom(let string): return string
            }
        }

        // MARK: Case name
        public var caseName : String {
            switch self {
                case .aac: return "aac"
                case .abw: return "abw"
                case .apng: return "apng"
                case .arc: return "arc"
                case .avif: return "avif"
                case .avi: return "avi"
                case .azw: return "azw"
                case .bin: return "bin"
                case .bmp: return "bmp"
                case .bz: return "bz"
                case .bz2: return "bz2"
                case .cda: return "cda"
                case .csh: return "csh"
                case .css: return "css"
                case .csv: return "csv"
                case .doc: return "doc"
                case .docx: return "docx"
                case .eot: return "eot"
                case .epub: return "epub"
                case .gz: return "gz"
                case .gif: return "gif"
                case .htm: return "htm"
                case .html: return "html"
                case .ico: return "ico"
                case .ics: return "ics"
                case .jar: return "jar"
                case .jpeg: return "jpeg"
                case .jpg: return "jpg"
                case .js: return "js"
                case .javascript: return "javascript"
                case .json: return "json"
                case .jsonld: return "jsonld"
                case .mid: return "mid"
                case .midi: return "midi"
                case .mjs: return "mjs"
                case .mp3: return "mp3"
                case .mp4: return "mp4"
                case .mpeg: return "mpeg"
                case .mpkg: return "mpkg"
                case .odp: return "odp"
                case .ods: return "ods"
                case .odt: return "odt"
                case .oga: return "oga"
                case .ogv: return "ogv"
                case .ogx: return "ogx"
                case .opus: return "opus"
                case .otf: return "otf"
                case .png: return "png"
                case .pdf: return "pdf"
                case .php: return "php"
                case .ppt: return "ppt"
                case .pptx: return "pptx"
                case .rar: return "rar"
                case .rtf: return "rtf"
                case .sh: return "sh"
                case .svg: return "svg"
                case .tar: return "tar"
                case .tif: return "tif"
                case .tiff: return "tiff"
                case .ts: return "ts"
                case .ttf: return "ttf"
                case .txt: return "txt"
                case .vsd: return "vsd"
                case .wav: return "wav"
                case .weba: return "weba"
                case .webm: return "webm"
                case .webp: return "webp"
                case .woff: return "woff"
                case .woff2: return "woff2"
                case .xhtml: return "xhtml"
                case .xls: return "xls"
                case .xlsx: return "xlsx"
                case .xml: return "xml"
                case .xul: return "xul"
                case .zip: return "zip"
                case ._3gp: return "_3gp"
                case ._3g2: return "_3g2"
                case ._7z: return "_7z"
                case .custom(let value): return "custom(\"\(value)\")"
            }
        }
    }
}