
import DestinyBlueprint

public enum HTTPMediaTypeText: HTTPMediaTypeProtocol {
    case _1dInterleavedParityfec
    case cacheManifest
    case calendar
    case cql
    case cqlExpression
    case cqlIdentifier
    case css
    case csv
    case csvSchema
    case dns
    case encaprtp
    case enriched
    case example
    case fhirpath
    case flexfec
    case fwdred
    case gff3
    case grammarRefList
    case hl7v2
    case html
    case javascript
    case jcrCND
    case markdown
    case mizar
    case n3
    case parameters
    case parityfec
    case plain
    case provenanceNotation
    case prsFallensteinRST
    case prsLinesTag
    case prsPropLogic
    case prsTexi
    case raptorfec
    case red
    case rfc822Headers
    case richtext
    case rtf
    case rtpEncAescm128
    case rtploopback
    case rtx
    case sgml
    case shaclc
    case shex
    case spdx
    case strings
    case t140
    case tabSeparatedValues
    case troff
    case turtle
    case ulpfec
    case uriList
    case vcard
    case a
    case abc
    case asciiArt
    case curl
    case debianCopyright
    case dmClientScript
    case dvbSubtitle
    case esmertecThemeDescriptor
    case exchangeable
    case familySearchGedcom
    case ficlabFLT
    case fmiFlexstor
    case gml
    case graphviz
    case hans
    case hgl
    case in3d3dml
    case in3dSpot
    case iptcNewsML
    case iptcNITF
    case latexZ
    case motorolaReflex
    case msMediapackage
    case net2phoneCommCenterCommand
    case radisysMsmlBasicLayout
    case senxWarpscript
    case sunJ2meAppDescriptor
    case sosi
    case trolltechLinguist
    case vcf
    case wapSi
    case wapSl
    case wapWmlscript
    case zooKCL
    case vtt
    case wgsl
    case xml
    case xmlExternalParsedEntity

    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        case "ics": self = .calendar
        case "csv": self = .csv
        case "html": self = .html
        case "js": self = .javascript
        case "md", "markdown": self = .markdown
        case "n3": self = .n3
        case "txt": self = .plain
        case "xml": self = .xml
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var type: String {
        "text"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case ._1dInterleavedParityfec: "1d-interleaved-parityfec"
        case .cacheManifest: "cache-manifest"
        case .calendar: "calendar"
        case .cql: "cql"
        case .cqlExpression: "cql-expression"
        case .cqlIdentifier: "cql-identifier"
        case .css: "css"
        case .csv: "csv"
        case .csvSchema: "csv-schema"
        case .dns: "dns"
        case .encaprtp: "encaprtp"
        case .enriched: "enriched"
        case .example: "example"
        case .fhirpath: "fhirpath"
        case .flexfec: "flexfec"
        case .fwdred: "fwdred"
        case .gff3: "gff3"
        case .grammarRefList: "grammar-ref-list"
        case .hl7v2: "hl7v2"
        case .html: "html"
        case .javascript: "javascript"
        case .jcrCND: "jcr-cnd"
        case .markdown: "markdown"
        case .mizar: "mizar"
        case .n3: "n3"
        case .parameters: "parameters"
        case .parityfec: "parityfec"
        case .plain: "plain"
        case .provenanceNotation: "provenance-notation"
        case .prsFallensteinRST: "prs.fallenstein.rst"
        case .prsLinesTag: "prs.lines.tag"
        case .prsPropLogic: "prs.prop.logic"
        case .prsTexi: "prs.texi"
        case .raptorfec: "raptorfec"
        case .red: "RED"
        case .rfc822Headers: "rfc822-headers"
        case .richtext: "richtext"
        case .rtf: "rtf"
        case .rtpEncAescm128: "rtp-enc-aescm128"
        case .rtploopback: "rtploopback"
        case .rtx: "rtx"
        case .sgml: "SGML"
        case .shaclc: "shaclc"
        case .shex: "shex"
        case .spdx: "spdx"
        case .strings: "strings"
        case .t140: "t140"
        case .tabSeparatedValues: "tab-separated-values"
        case .troff: "troff"
        case .turtle: "turtle"
        case .ulpfec: "ulpfec"
        case .uriList: "uri-list"
        case .vcard: "vcard"
        case .a: "vnd.a"
        case .abc: "vnd.abc"
        case .asciiArt: "vnd.ascii-art"
        case .curl: "vnd.curl"
        case .debianCopyright: "vnd.debian.copyright"
        case .dmClientScript: "vnd.DMClientScript"
        case .dvbSubtitle: "vnd.dvb.subtitle"
        case .esmertecThemeDescriptor: "vnd.esmertec.theme-descriptor"
        case .exchangeable: "vnd.exchangeable"
        case .familySearchGedcom: "vnd.familysearch.gedcom"
        case .ficlabFLT: "vnd.ficlab.flt"
        case .fmiFlexstor: "vnd.fmi.flexstor"
        case .gml: "vnd.gml"
        case .graphviz: "vnd.graphviz"
        case .hans: "vnd.hans"
        case .hgl: "vnd.hgl"
        case .in3d3dml: "vnd.in3d.3dml"
        case .in3dSpot: "vnd.in3d.spot"
        case .iptcNewsML: "vnd.IPTC.NewsML"
        case .iptcNITF: "vnd.IPTC.NITF"
        case .latexZ: "vnd.latex-z"
        case .motorolaReflex: "vnd.motorola.reflex"
        case .msMediapackage: "vnd.ms-mediapackage"
        case .net2phoneCommCenterCommand: "vnd.net2phone.commcenter.command"
        case .radisysMsmlBasicLayout: "vnd.radisys.msml-basic-layout"
        case .senxWarpscript: "vnd.senx.warpscript"
        case .sunJ2meAppDescriptor: "vnd.sun.j2me.app-descriptor"
        case .sosi: "vnd.sosi"
        case .trolltechLinguist: "vnd.trolltech.linguist"
        case .vcf: "vnd.vcf"
        case .wapSi: "vnd.wap.si"
        case .wapSl: "vnd.wap.sl"
        case .wapWmlscript: "vnd.wap.wmlscript"
        case .zooKCL: "vnd.zoo.kcl"
        case .vtt: "vtt"
        case .wgsl: "wgsl"
        case .xml: "xml"
        case .xmlExternalParsedEntity: "xml-external-parsed-entity"
        }
    }
}