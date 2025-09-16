
import DestinyDefaults

extension HTTPMediaTypeText: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "_1dInterleavedParityfec": self = ._1dInterleavedParityfec
        case "cacheManifest": self = .cacheManifest
        case "calendar": self = .calendar
        case "cql": self = .cql
        case "cqlExpression": self = .cqlExpression
        case "cqlIdentifier": self = .cqlIdentifier
        case "css": self = .css
        case "csv": self = .csv
        case "csvSchema": self = .csvSchema
        case "dns": self = .dns
        case "encaprtp": self = .encaprtp
        case "enriched": self = .enriched
        case "example": self = .example
        case "fhirpath": self = .fhirpath
        case "flexfec": self = .flexfec
        case "fwdred": self = .fwdred
        case "gff3": self = .gff3
        case "grammarRefList": self = .grammarRefList
        case "hl7v2": self = .hl7v2
        case "html": self = .html
        case "javascript": self = .javascript
        case "jcrCND": self = .jcrCND
        case "markdown": self = .markdown
        case "mizar": self = .mizar
        case "n3": self = .n3
        case "parameters": self = .parameters
        case "parityfec": self = .parityfec
        case "plain": self = .plain
        case "provenanceNotation": self = .provenanceNotation
        case "prsFallensteinRST": self = .prsFallensteinRST
        case "prsLinesTag": self = .prsLinesTag
        case "prsPropLogic": self = .prsPropLogic
        case "prsTexi": self = .prsTexi
        case "raptorfec": self = .raptorfec
        case "red": self = .red
        case "rfc822Headers": self = .rfc822Headers
        case "richtext": self = .richtext
        case "rtf": self = .rtf
        case "rtpEncAescm128": self = .rtpEncAescm128
        case "rtploopback": self = .rtploopback
        case "rtx": self = .rtx
        case "sgml": self = .sgml
        case "shaclc": self = .shaclc
        case "shex": self = .shex
        case "spdx": self = .spdx
        case "strings": self = .strings
        case "t140": self = .t140
        case "tabSeparatedValues": self = .tabSeparatedValues
        case "troff": self = .troff
        case "turtle": self = .turtle
        case "ulpfec": self = .ulpfec
        case "uriList": self = .uriList
        case "vcard": self = .vcard
        case "a": self = .a
        case "abc": self = .abc
        case "asciiArt": self = .asciiArt
        case "curl": self = .curl
        case "debianCopyright": self = .debianCopyright
        case "dmClientScript": self = .dmClientScript
        case "dvbSubtitle": self = .dvbSubtitle
        case "esmertecThemeDescriptor": self = .esmertecThemeDescriptor
        case "exchangeable": self = .exchangeable
        case "familySearchGedcom": self = .familySearchGedcom
        case "ficlabFLT": self = .ficlabFLT
        case "fmiFlexstor": self = .fmiFlexstor
        case "gml": self = .gml
        case "graphviz": self = .graphviz
        case "hans": self = .hans
        case "hgl": self = .hgl
        case "in3d3dml": self = .in3d3dml
        case "in3dSpot": self = .in3dSpot
        case "iptcNewsML": self = .iptcNewsML
        case "iptcNITF": self = .iptcNITF
        case "latexZ": self = .latexZ
        case "motorolaReflex": self = .motorolaReflex
        case "msMediapackage": self = .msMediapackage
        case "net2phoneCommCenterCommand": self = .net2phoneCommCenterCommand
        case "radisysMsmlBasicLayout": self = .radisysMsmlBasicLayout
        case "senxWarpscript": self = .senxWarpscript
        case "sunJ2meAppDescriptor": self = .sunJ2meAppDescriptor
        case "sosi": self = .sosi
        case "trolltechLinguist": self = .trolltechLinguist
        case "vcf": self = .vcf
        case "wapSi": self = .wapSi
        case "wapSl": self = .wapSl
        case "wapWmlscript": self = .wapWmlscript
        case "zooKCL": self = .zooKCL
        case "vtt": self = .vtt
        case "wgsl": self = .wgsl
        case "xml": self = .xml
        case "xmlExternalParsedEntity": self = .xmlExternalParsedEntity
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case ._1dInterleavedParityfec: "_1dInterleavedParityfec"
        case .cacheManifest: "cacheManifest"
        case .calendar: "calendar"
        case .cql: "cql"
        case .cqlExpression: "cqlExpression"
        case .cqlIdentifier: "cqlIdentifier"
        case .css: "css"
        case .csv: "csv"
        case .csvSchema: "csvSchema"
        case .dns: "dns"
        case .encaprtp: "encaprtp"
        case .enriched: "enriched"
        case .example: "example"
        case .fhirpath: "fhirpath"
        case .flexfec: "flexfec"
        case .fwdred: "fwdred"
        case .gff3: "gff3"
        case .grammarRefList: "grammarRefList"
        case .hl7v2: "hl7v2"
        case .html: "html"
        case .javascript: "javascript"
        case .jcrCND: "jcrCND"
        case .markdown: "markdown"
        case .mizar: "mizar"
        case .n3: "n3"
        case .parameters: "parameters"
        case .parityfec: "parityfec"
        case .plain: "plain"
        case .provenanceNotation: "provenanceNotation"
        case .prsFallensteinRST: "prsFallensteinRST"
        case .prsLinesTag: "prsLinesTag"
        case .prsPropLogic: "prsPropLogic"
        case .prsTexi: "prsTexi"
        case .raptorfec: "raptorfec"
        case .red: "red"
        case .rfc822Headers: "rfc822Headers"
        case .richtext: "richtext"
        case .rtf: "rtf"
        case .rtpEncAescm128: "rtpEncAescm128"
        case .rtploopback: "rtploopback"
        case .rtx: "rtx"
        case .sgml: "sgml"
        case .shaclc: "shaclc"
        case .shex: "shex"
        case .spdx: "spdx"
        case .strings: "strings"
        case .t140: "t140"
        case .tabSeparatedValues: "tabSeparatedValues"
        case .troff: "troff"
        case .turtle: "turtle"
        case .ulpfec: "ulpfec"
        case .uriList: "uriList"
        case .vcard: "vcard"
        case .a: "a"
        case .abc: "abc"
        case .asciiArt: "asciiArt"
        case .curl: "curl"
        case .debianCopyright: "debianCopyright"
        case .dmClientScript: "dmClientScript"
        case .dvbSubtitle: "dvbSubtitle"
        case .esmertecThemeDescriptor: "esmertecThemeDescriptor"
        case .exchangeable: "exchangeable"
        case .familySearchGedcom: "familySearchGedcom"
        case .ficlabFLT: "ficlabFLT"
        case .fmiFlexstor: "fmiFlexstor"
        case .gml: "gml"
        case .graphviz: "graphviz"
        case .hans: "hans"
        case .hgl: "hgl"
        case .in3d3dml: "in3d3dml"
        case .in3dSpot: "in3dSpot"
        case .iptcNewsML: "iptcNewsML"
        case .iptcNITF: "iptcNITF"
        case .latexZ: "latexZ"
        case .motorolaReflex: "motorolaReflex"
        case .msMediapackage: "msMediapackage"
        case .net2phoneCommCenterCommand: "net2phoneCommCenterCommand"
        case .radisysMsmlBasicLayout: "radisysMsmlBasicLayout"
        case .senxWarpscript: "senxWarpscript"
        case .sunJ2meAppDescriptor: "sunJ2meAppDescriptor"
        case .sosi: "sosi"
        case .trolltechLinguist: "trolltechLinguist"
        case .vcf: "vcf"
        case .wapSi: "wapSi"
        case .wapSl: "wapSl"
        case .wapWmlscript: "wapWmlscript"
        case .zooKCL: "zooKCL"
        case .vtt: "vtt"
        case .wgsl: "wgsl"
        case .xml: "xml"
        case .xmlExternalParsedEntity: "xmlExternalParsedEntity"
        }
    }
}