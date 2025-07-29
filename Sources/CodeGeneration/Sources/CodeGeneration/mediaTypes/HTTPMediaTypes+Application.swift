
extension HTTPMediaTypes {
    static var applicationMediaTypes: [HTTPMediaType] {
        [
            .init("calendarJSON", "calendar+json"),
            .init("calendarXML", "calendar+xml"),

            .init("dns", ""),
            .init("dnsJSON", "dns+json"),
            .init("dnsMessage", "dns-message"),

            .init("example", ""),
            .init("excel", "vnd.ms-excel"),

            .init("geoJSON", "geo+json", fileExtensions: ["geojson"]),
            .init("geoJSONSeq", "geo+json-seq"),
            .init("gzip", "", fileExtensions: ["gz"]),

            .init("http", ""),

            .init("index", ""),

            .init("json", "", fileExtensions: ["json"]),
            .init("jsonPatchJSON", "json-patch+json", fileExtensions: ["json-patch"]),
            .init("jsonSeq", "json-seq"),
            .init("jsonpath", ""),
            .init("jwkJSON", "jwk+json"),
            .init("jwkSetJSON", "jwk-set+json"),
            .init("jwkSetJWT", "jwk-set+jwt"),
            .init("jwt", ""),

            .init("ldJSON", "ld+json", fileExtensions: ["jsonld"]),

            .init("manifestJSON", "manifest+json"),
            .init("mp4", "", fileExtensions: ["mp4"]),
            .init("msword", ""),
            .init("nasdata", ""),
            .init("node", ""),
            .init("nss", ""),

            .init("ogg", ""),

            .init("pdf", "", fileExtensions: ["pdf"]),
            .init("pdx", "PDX"),
            .init("pemCertificateChain", "pem-certificate-chain"),
            .init("pgpEncrypted", "php-encrypted"),
            .init("pgpKeys", "pgp-keys"),
            .init("pgpSignature", "pgp-signature"),
            .init("portableExecutable", "vnd.microsoft.portable-executable"),
            .init("powerpoint", "vnd.ms-powerpoint"),

            .init("rtf", "", fileExtensions: ["rtf"]),
            .init("rtploopback", ""),
            .init("rtx", ""),

            .init("sql", "", fileExtensions: ["sql"]),

            .init("vc", "", fileExtensions: ["vc"]),

            .init("adobeFlashMovie", "vnd.adobe.flash.movie", fileExtensions: ["swf"]),
            .init("appleInstallerXML", "vnd.apple.installer+xml", fileExtensions: ["dist", "distz", "pkg", "mpkg"]),
            .init("appleKeynote", "vnd.apple.keynote", fileExtensions: ["key"]),
            .init("appleMpegURL", "vnd.apple.mpegurl", fileExtensions: ["m3u8", "m3u"]),
            .init("appleNumbers", "vnd.apple.numbers", fileExtensions: ["numbers"]),
            .init("applePages", "vnd.apple.pages", fileExtensions: ["pages"]),

            .init("chessPGN", "vnd.chess-pgn", fileExtensions: ["pgn"]),
            .init("curl", "vnd.curl"),

            .init("dart", "vnd.dart"),
            .init("dna", "vnd.dna", fileExtensions: ["dna"]),

            .init("herokuJSON", "vnd.heroku+json"),

            .init("kahootz", "vnd.kahootz"),

            .init("rar", "vnd.rar", fileExtensions: ["rar"]),

            .init("wasm", "", fileExtensions: ["wasm"]),

            .init("xwwwFormURLEncoded", "x-www-form-urlencoded"),
            .init("xx509CACert", "x-x509-ca-cert"),
            .init("xx509CARACert", "x-x509-ca-ra-cert"),
            .init("xx509NextCACert", "x-x509-next-ca-cert"),

            .init("xml", "", fileExtensions: ["xml"]),
            .init("xGoogleProtobuf", "x-google-protobuf"),
            .init("xProtobuf", "x-protobuf"),

            .init("yaml", "", fileExtensions: ["yaml", "yml"]),
            .init("yang", "", fileExtensions: ["yang"]),

            .init("zip", "", fileExtensions: ["zip"]),
            .init("zlib", ""),
            .init("zstd", "", fileExtensions: ["zst"])
        ]
    }
}