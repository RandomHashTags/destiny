import DestinyBlueprint

public enum HTTPMediaTypeText: String, HTTPMediaTypeProtocol {
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

    @inlinable
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

    @inlinable
    public var type: String {
        "text"
    }

    @inlinable
    public var subType: String {
        switch self {
        case ._1dInterleavedParityfec: "1d-interleaved-parityfec"
        case .cacheManifest: "cache-manifest"
        case .calendar: rawValue
        case .cql: rawValue
        case .cqlExpression: "cql-expression"
        case .cqlIdentifier: "cql-identifier"
        case .css: rawValue
        case .csv: rawValue
        case .csvSchema: "csv-schema"
        case .dns: rawValue
        case .encaprtp: rawValue
        case .enriched: rawValue
        case .example: rawValue
        case .fhirpath: rawValue
        case .flexfec: rawValue
        case .fwdred: rawValue
        case .gff3: rawValue
        case .grammarRefList: "grammar-ref-list"
        case .hl7v2: rawValue
        case .html: rawValue
        case .javascript: rawValue
        case .jcrCND: "jcr-cnd"
        case .markdown: rawValue
        case .mizar: rawValue
        case .n3: rawValue
        case .parameters: rawValue
        case .parityfec: rawValue
        case .plain: rawValue
        case .provenanceNotation: "provenance-notation"
        case .prsFallensteinRST: "prs.fallenstein.rst"
        case .prsLinesTag: "prs.lines.tag"
        case .prsPropLogic: "prs.prop.logic"
        case .prsTexi: "prs.texi"
        case .raptorfec: rawValue
        case .red: "RED"
        case .rfc822Headers: "rfc822-headers"
        case .richtext: rawValue
        case .rtf: rawValue
        case .rtpEncAescm128: "rtp-enc-aescm128"
        case .rtploopback: rawValue
        case .rtx: rawValue
        case .sgml: "SGML"
        case .shaclc: rawValue
        case .shex: rawValue
        case .spdx: rawValue
        case .strings: rawValue
        case .t140: rawValue
        case .tabSeparatedValues: "tab-separated-values"
        case .troff: rawValue
        case .turtle: rawValue
        case .ulpfec: rawValue
        case .uriList: "uri-list"
        case .vcard: rawValue
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
        case .vtt: rawValue
        case .wgsl: rawValue
        case .xml: rawValue
        case .xmlExternalParsedEntity: "xml-external-parsed-entity"
        }
    }
}