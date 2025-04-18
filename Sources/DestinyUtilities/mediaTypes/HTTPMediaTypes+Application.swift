//
//  HTTPMediaTypes+Application.swift
//
//
//  Created by Evan Anderson on 12/30/24.
//

extension HTTPMediaType {
    #HTTPFieldContentType(
        category: "application",
        values: [
            "calendarJSON" : .init("calendar+json"),
            "calendarXML" : .init("calendar+xml"),

            "dns" : .init(""),
            "dnsJSON" : .init("dns+json"),
            "dnsMessage" : .init("dns-message"),

            "example" : .init(""),
            "excel" : .init("vnd.ms-excel"),

            "geoJSON" : .init("geo+json", fileExtensions: ["geojson"]),
            "geoJSONSeq" : .init("geo+json-seq"),
            "gzip" : .init("", fileExtensions: ["gz"]),

            "http" : .init(""),

            "index" : .init(""),

            "json" : .init("", fileExtensions: ["json"]),
            "jsonPatchJSON" : .init("json-patch+json", fileExtensions: ["json-patch"]),
            "jsonSeq" : .init("json-seq"),
            "jsonpath" : .init(""),
            "jwkJSON" : .init("jwk+json"),
            "jwkSetJSON" : .init("jwk-set+json"),
            "jwkSetJWT" : .init("jwk-set+jwt"),
            "jwt" : .init(""),

            "ldJSON" : .init("ld+json", fileExtensions: ["jsonld"]),

            "manifestJSON" : .init("manifest+json"),
            "mp4" : .init("", fileExtensions: ["mp4"]),
            "msword" : .init(""),
            "nasdata" : .init(""),
            "node" : .init(""),
            "nss" : .init(""),

            "ogg" : .init(""),

            "pdf" : .init("", fileExtensions: ["pdf"]),
            "pdx" : .init("PDX"),
            "pemCertificateChain" : .init("pem-certificate-chain"),
            "pgpEncrypted" : .init("php-encrypted"),
            "pgpKeys" : .init("pgp-keys"),
            "pgpSignature" : .init("pgp-signature"),
            "portableExecutable" : .init("vnd.microsoft.portable-executable"),
            "powerpoint" : .init("vnd.ms-powerpoint"),

            "rtf" : .init("", fileExtensions: ["rtf"]),
            "rtploopback" : .init(""),
            "rtx" : .init(""),

            "sql" : .init("", fileExtensions: ["sql"]),

            "vc" : .init("", fileExtensions: ["vc"]),

            "adobeFlashMovie" : .init("vnd.adobe.flash.movie", fileExtensions: ["swf"]),
            "appleInstallerXML" : .init("vnd.apple.installer+xml", fileExtensions: ["dist", "distz", "pkg", "mpkg"]),
            "appleKeynote" : .init("vnd.apple.keynote", fileExtensions: ["key"]),
            "appleMpegURL" : .init("vnd.apple.mpegurl", fileExtensions: ["m3u8", "m3u"]),
            "appleNumbers" : .init("vnd.apple.numbers", fileExtensions: ["numbers"]),
            "applePages" : .init("vnd.apple.pages", fileExtensions: ["pages"]),

            "chessPGN" : .init("vnd.chess-pgn", fileExtensions: ["pgn"]),
            "curl" : .init("vnd.curl"),

            "dart" : .init("vnd.dart"),
            "dna" : .init("vnd.dna", fileExtensions: ["dna"]),

            "herokuJSON" : .init("vnd.heroku+json"),

            "kahootz" : .init("vnd.kahootz"),

            "rar" : .init("vnd.rar", fileExtensions: ["rar"]),

            "wasm" : .init("", fileExtensions: ["wasm"]),

            "xwwwFormURLEncoded" : .init("x-www-form-urlencoded"),
            "xx509CACert" : .init("x-x509-ca-cert"),
            "xx509CARACert" : .init("x-x509-ca-ra-cert"),
            "xx509NextCACert" : .init("x-x509-next-ca-cert"),

            "xml" : .init("", fileExtensions: ["xml"]),
            "xGoogleProtobuf" : .init("x-google-protobuf"),
            "xProtobuf" : .init("x-protobuf"),

            "yaml" : .init("", fileExtensions: ["yaml", "yml"]),
            "yang" : .init("", fileExtensions: ["yang"]),

            "zip" : .init("", fileExtensions: ["zip"]),
            "zlib" : .init(""),
            "zstd" : .init("", fileExtensions: ["zst"])
        ]
    )
}