//
//  HTTPMediaType.swift
//
//
//  Created by Evan Anderson on 10/27/24.
//

import HTTPTypes

/// All recognized media types by the IANA (https://www.iana.org/assignments/media-types/media-types.xhtml), with additional media types.
/// 
/// Additional Media Types
/// - xGoogleProtobuf & xProtobuf: Protocol Buffers (https://protobuf.dev/)
@HTTPFieldContentTypes(
    application: [
        "calendarJSON" : "calendar+json",
        "calendarXML" : "calendar+xml",

        "dns" : "",
        "dnsJSON" : "dns+json",
        "dnsMessage" : "dns-message",

        "example" : "",

        "geoJSON" : "geo+json",
        "geoJSONSeq" : "geo+json-seq",
        "gzip" : "",

        "index" : "",

        "json" : "",
        "jsonPatchJSON" : "json-patch+json",
        "jsonSeq" : "json-seq",
        "jsonpath" : "",
        "jwkJSON" : "jwk+json",
        "jwkSetJSON" : "jwk-set+json",
        "jwkSetJWT" : "jwk-set+jwt",
        "jwt" : "",

        "manifestJSON" : "manifest+json",
        "mp4" : "",
        "msword" : "",
        "nasdata" : "",
        "node" : "",
        "nss" : "",

        "ogg" : "",

        "pdf" : "",
        "pdx" : "PDX",
        "pemCertificateChain" : "pem-certificate-chain",
        "pgpEncrypted" : "php-encrypted",
        "pgpKeys" : "pgp-keys",
        "pgpSignature" : "pgp-signature",

        "rtf" : "",
        "rtploopback" : "",
        "rtx" : "",

        "sql" : "",

        "adobeFlashMovie" : "vnd.adobe.flash.movie",
        "appleInstallerXML" : "vnd.apple.installer+xml",
        "appleKeynote" : "vnd.apple.keynote",
        "appleMpegURL" : "vnd.apple.mpegurl",
        "appleNumbers" : "vnd.apple.numbers",
        "applePages" : "vnd.apple.pages",

        "curl" : "vnd.curl",

        "dart" : "vnd.dart",
        "dna" : "vnd.dna",

        "herokuJSON" : "vnd.heroku+json",

        "kahootz" : "vnd.kahootz",

        "rar" : "vnd.rar",

        "wasm" : "",

        "xwwwFormURLEncoded" : "x-www-form-urlencoded",
        "xx509CACert" : "x-x509-ca-cert",
        "xx509CARACert" : "x-x509-ca-ra-cert",
        "xx509NextCACert" : "x-x509-next-ca-cert",

        "xml" : "",
        "xGoogleProtobuf" : "x-google-protobuf",
        "xProtobuf" : "x-protobuf",

        "yaml" : "",
        "yang" : "",

        "zip" : "",
        "zlib" : "",
        "zstd" : ""
    ],
    audio: [:],
    font: [
        "collection" : "",
        "otf" : "",
        "sfnt" : "",
        "ttf" : "",
        "woff" : "",
        "woff2" : ""
    ],
    haptics: [
        "ivs" : "",
        "hjif" : "",
        "hmpg" : ""
    ],
    image: [
        "aces" : "",
        "apng" : "",
        "avci" : "",
        "avcs" : "",
        "avif" : "",
        "bmp" : "",
        "cgm" : "",
        "dicomRLE" : "dicom-rle",
        "dpx" : "",
        "emf" : "",
        "example" : "",
        "fits" : "",
        "g3fax" : "",
        "gif" : "",
        "heic" : "",
        "heicSequence" : "heic-sequence",
        "heif" : "",
        "heifSequence" : "heif-sequence",
        "hej2k" : "",
        "ief" : "",
        "j2c" : "",
        "jls" : "",
        "jp2" : "",
        "jpeg" : "",
        "jph" : "",
        "jphc" : "",
        "jpm" : "",
        "jpx" : "",
        "jxl" : "",
        "jxr" : "",
        "jxrA" : "",
        "jxrS" : "",
        "jxs" : "",
        "jxsc" : "",
        "jxsi" : "",
        "jxss" : "",
        "ktx" : "",
        "ktx2" : "",
        "naplps" : "",
        "png" : "",
        "prsBTIF" : "prs.btif",
        "prsPTI" : "prs.bti",
        "pwgRaster" : "pwg-raster",
        "svgXML" : "svg+xml",
        "t38" : "",
        "tiff" : "",
        "tiffFX" : "tiff-fx",
        "psd" : "vnd.adobe.photoshop",
        "airzipAcceleratorAZV" : "cnd.airzip.accelerator.azv",
        "cnsINF2" : "vnd.cns.inf2",
        "deceGraphic" : "vnd.dece.graphic",
        "djvu" : "vnd.djvu",
        "dwg" : "vnd.dwg",
        "dxf" : "vnd.dxf",
        "dvbSubtitle" : "vnd.dvb.subtitle",
        "fastbidsheet" : "vnd.fastbidsheet",
        "fpx" : "vnd.fpx",
        "fst" : "vnd.fst",
        "fujixeroxEdmicsMMR" : "vnd.fujixerox.edmics-mmr",
        "fujixeroxEdmicsRLC" : "vnd.fujixerox.edmics-rlc",
        "globalGraphicsPGB" : "vnd.globalgraphics.pgb",
        "microsoftIcon" : "vnd.microsoft.icon",
        "mix" : "vnd.mix",
        "msModi" : "vnd.ms-modi",
        "mozillaAPNG" : "vnd.mozilla.apng",
        "netFPX" : "vnd.net-fpx",
        "pcoB16" : "vnd.pco.b16",
        "radiance" : "vnd.radiance",
        "sealedPNG" : "vnd.sealed.png",
        "sealedMediaSoftSealGIF" : "vnd.sealedmedia.softseal.gif",
        "sealedMediaSoftSealJPG" : "vnd.sealedmedia.softseal.jpg",
        "svf" : "vnd.svf",
        "tencentTap" : "vnd.tencent.tap",
        "vtf" : "vnd.valve.source.texture",
        "wapWBMP" : "vnd.wap.wbmp",
        "xiff" : "vnd.xiff",
        "zbrushPCX" : "vnd.zbrush.pcx",
        "webp" : "",
        "wmf" : ""
    ],
    message: [
        "bhttp" : "",
        "cpim" : "CPIM",
        "deliveryStatus" : "delivery-status",
        "dispositionNotification" : "disposition-notification",
        "example" : "",
        "externalBody" : "external-body",
        "feedbackReport" : "feedback-report",
        "global" : "",
        "globalDeliveryStatus" : "global-delivery-status",
        "globalDispositionNotification" : "global-disposition-notification",
        "globalHeaders" : "global-headers",
        "http" : "",
        "imdnXML" : "imdn+xml",
        "mls" : "",
        "ohttpReq" : "ohttp-req",
        "ohttpRes" : "ohttp-res",
        "partial" : "",
        "rfc822" : "",
        "sip" : "",
        "sipfrag" : "",
        "trackingStatus" : "tracking-status",
        "wsc" : "vnd.wfa.wsc"
    ],
    model: [
        "_3mf" : "3mf",
        "e57" : "",
        "example" : "",
        "gltfBinary" : "gltf-binary",
        "gltfJSON" : "gltf+json",
        "jt" : "JT",
        "iges" : "",
        "mesh" : "",
        "mtl" : "",
        "obj" : "",
        "prc": "",
        "step" : "",
        "stepXML" : "step+xml",
        "stepZip" : "step+zip",
        "stepXMLZip" : "step-xml+zip",
        "stl" : "",
        "u3d" : "",
        "bary" : "vnd.bary",
        "cld" : "vnd.cld",
        "colladaXML" : "vnd.collada+xml",
        "dwf" : "vnd.dwf",
        "_3dm" : "vnd.flatland.3dml",
        "_3dml" : "vnd.flatland.3dml",
        "gdl" : "vnd.gld",
        "gsGdl" : "vnd.gs-gdl",
        "gtw" : "vnd.gtw",
        "momlXML" : "vnd.moml+xml",
        "mts" : "vnd.mts",
        "opengex" : "vnd.opengex",
        "parasolidTransmitBinary" : "vnd.parasolid.transmit.binary",
        "parasolidTransmitText" : "vnd.parasolid.transmit.text",
        "pythaPyox" : "vnd.pytha.pyox",
        "rosetteAnnotatedDataModel" : "vnd.rosette.annotated-data-model",
        "sapVds" : "vnd.sap.vds",
        "usda" : "vnd.usda",
        "usdz" : "vnd.usdz+zip",
        "bsp" : "vnd.valve.source.compiled-map",
        "vtu" : "vnd.vtu",
        "vrml" : "vrml",
        "x3dv" : "x3d-vrml",
        "x3db" : "x3d+fastinfoset"
    ],
    multipart: [
        "alternative" : "",
        "appledouble" : "",
        "byteranges" : "",
        "digest" : "",
        "encrypted" : "",
        "example" : "",
        "formData" : "form-data",
        "headerSet" : "header-set",
        "mixed" : "",
        "multilingual" : "",
        "parallel" : "",
        "related" : "",
        "report" : "",
        "signed" : "",
        "medPlus" : "vnd.bint.med-plus",
        "voiceMessage" : "voice-message",
        "xMixedReplace" : "x-mixed-replace"
    ],
    text: [
        "_1dInterleavedParityfec" : "1d-interleaved-parityfec",
        "cacheManifest" : "cache-manifest",
        "calendar" : "",
        "cql" : "",
        "cqlExpression" : "cql-expression",
        "cqlIdentifier" : "cql-identifier",
        "css" : "",
        "csv" : "",
        "csvSchema" : "csv-schema",
        "dns" : "",
        "encaprtp" : "",
        "enriched" : "",
        "example" : "",
        "fhirpath" : "",
        "flexfec" : "",
        "fwdred" : "",
        "gff3" : "",
        "grammarRefList" : "grammar-ref-list",
        "hl7v2" : "",
        "html" : "",
        "javascript" : "",
        "jcrCND" : "jcr-cnd",
        "markdown" : "",
        "mizar" : "",
        "n3" : "",
        "parameters" : "",
        "parityfec" : "",
        "plain" : "",
        "provenanceNotation" : "provenance-notation",
        "prsFallensteinRST" : "prs.fallenstein.rst",
        "prsLinesTag" : "prs.lines.tag",
        "prsPropLogic" : "prs.prop.logic",
        "prsTexi" : "prs.texi",
        "raptorfec" : "",
        "red" : "RED",
        "rfc822Headers" : "rfc822-headers",
        "richtext" : "",
        "rtf" : "",
        "rtpEncAescm128" : "rtp-enc-aescm128",
        "rtploopback" : "",
        "rtx" : "",
        "sgml" : "SGML",
        "shaclc" : "",
        "shex" : "",
        "spdx" : "",
        "strings" : "",
        "t140" : "",
        "tabSeparatedValues" : "tab-separated-values",
        "troff" : "",
        "turtle" : "",
        "ulpfec" : "",
        "uriList" : "uri-list",
        "vcard" : "",
        "a" : "vnd.a",
        "abc" : "vnd.abc",
        "asciiArt" : "vnd.ascii-art",
        "curl" : "vnd.curl",
        "debianCopyright" : "vnd.debian.copyright",
        "dmClientScript" : "vnd.DMClientScript",
        "dvbSubtitle" : "vnd.dvb.subtitle",
        "esmertecThemeDescriptor" : "vnd.esmertec.theme-descriptor",
        "exchangeable" : "vnd.exchangeable",
        "familySearchGedcom" : "vnd.familysearch.gedcom",
        "ficlabFLT" : "vnd.ficlab.flt",
        "fmiFlexstor" : "vnd.fmi.flexstor",
        "gml" : "vnd.gml",
        "graphviz" : "vnd.graphviz",
        "hans" : "vnd.hans",
        "hgl" : "vnd.hgl",
        "in3d3dml" : "vnd.in3d.3dml",
        "in3dSpot" : "vnd.in3d.spot",
        "iptcNewsML" : "vnd.IPTC.NewsML",
        "iptcNITF" : "vnd.IPTC.NITF",
        "latexZ" : "vnd.latex-z",
        "motorolaReflex" : "vnd.motorola.reflex",
        "msMediapackage" : "vnd.ms-mediapackage",
        "net2phoneCommCenterCommand" : "vnd.net2phone.commcenter.command",
        "radisysMsmlBasicLayout" : "vnd.radisys.msml-basic-layout",
        "senxWarpscript" : "vnd.senx.warpscript",
        "sunJ2meAppDescriptor" : "vnd.sun.j2me.app-descriptor",
        "sosi" : "vnd.sosi",
        "trolltechLinguist" : "vnd.trolltech.linguist",
        "vcf" : "vnd.vcf",
        "wapSi" : "vnd.wap.si",
        "wapSl" : "vnd.wap.sl",
        "wapWmlscript" : "vnd.wap.wmlscript",
        "zooKCL" : "vnd.zoo.kcl",
        "vtt" : "",
        "wgsl" : "",
        "xml" : "",
        "xmlExternalParsedEntity" : "xml-external-parsed-entity"
    ],
    video: [
        "_1dInterleavedParityfec" : "1d-interleaved-parityfec",
        "_3gpp" : "3gpp",
        "_3gpp2" : "3gpp2",
        "_3gppTT" : "3gpp-tt",
        "av1" : "AV1",
        "bmpeg" : "BMPEG",
        "bt656" : "BT656",
        "celB" : "CelB",
        "dv" : "DV",
        "encaprtp" : "",
        "enc" : "",
        "example" : "",
        "ffv1" : "FFV1",
        "flexfec" : "",
        "h261" : "H261",
        "h263" : "H263",
        "h263_2000" : "H263-2000",
        "h264" : "h264",
        "h264RCDO" : "H264-RCDO",
        "h264SVC" : "H264SVC",
        "h265" : "H265",
        "h266" : "H266",
        "isoSegment" : "iso.segment",
        "jpeg" : "JPEG",
        "jpeg2000" : "",
        "jxsv" : "",
        "matroska" : "",
        "matroska3d" : "matroska-3d",
        "mj2" : "",
        "mp1s" : "MP1S",
        "mp2p" : "MP2P",
        "mp2t" : "MP2T",
        "mp4" : "",
        "mp4VES" : "MP4V-ES",
        "mpv" : "MPV",
        "mpeg" : "",
        "mpeg4Generic" : "mpeg4-generic",
        "nv" : "",
        "ogg" : "",
        "parityfec" : "",
        "pointer" : "",
        "quicktime" : "",
        "raptorfec" : "",
        "raw" : "",
        "rptEncAescm128" : "rtp-enc-aescm128",
        "rtploopback" : "",
        "rtx" : "",
        "scip" : "",
        "smpte291" : "",
        "smpte292m" : "SMPTE292M",
        "ulpfec" : "",
        "vc1" : "",
        "vc2" : "",
        "cctv" : "vnd.CCTV",
        "deceHD" : "vnd.dece.hd",
        "deceMobile" : "vnd.dece.mobile",
        "deceMP4" : "vnd.dece.mp4",
        "decePD" : "vnd.dece.pd",
        "deceSD" : "vnd.dece.sd",
        "deceVideo" : "vnd.dece.video",
        "directvMPEG" : "vnd.directv.mpeg",
        "directvMPEGTTS" : "vnd.directv.mpegTTS",
        "dlnaMpegTTS" : "vnd.dlna.mpeg-tts",
        "dvbFile" : "vnd.dvb.file",
        "fvt" : "vnd.fvt",
        "hnsVideo" : "vnd.hns.video",
        "iptvforum1dparityfec1010" : "vnd.iptvforum.1dparityfec-1010",
        "iptvforum1dparityfec2005" : "vnd.iptvforum.1dparityfec-2005",
        "iptvforum2dparityfec1010" : "vnd.iptvforum.2dparityfec-1010",
        "iptvforum2dparityfec2005" : "vnd.iptvforum.2dparityfec-2005",
        "iptvforumTTSAVC" : "vnd.iptvforum.ttsavc",
        "iptvforumTTSMPEG2" : "vnd.iptvforum.ttsmpeg2",
        "motorolaVideo" : "vnd.motorola.video",
        "motorolaVideop" : "vnd.motorola.videop",
        "mpegurl" : "vnd.mpegurl",
        "pyv" : "vnd.ms-playready.media.pyv",
        "nokiaInterleavedMultimedia" : "vnd.nokia.interleaved-multimedia",
        "nokiaMP4VR" : "vnd.nokia.mp4vr",
        "nokiaVideoVOIP" : "vnd.nokia.videovoip",
        "objectvideo" : "vnd.objectvideo",
        "radgamettoolsBink" : "vnd.radgamettools.bink",
        "radgamettoolsSmacker" : "vnd.radgamettools.smacker",
        "sealedMPEG1" : "vnd.sealed.mpeg1",
        "sealedMPEG4" : "vnd.sealed.mpeg4",
        "sealedSWF" : "vnd.sealed.swf",
        "sealedMediaSoftSealMOV" : "vnd.sealedmedia.softseal.mov",
        "uvvuMP4" : "vnd.uvvu.mp4",
        "youtubeYT" : "vnd.youtube.yt",
        "vivo" : "vnd.vivo",
        "vp8" : "VP8",
        "vp9" : "VP9"
    ]
)
public struct HTTPMediaType : CustomDebugStringConvertible, CustomStringConvertible, Hashable, Sendable {
    public let rawValue:String
    public let caseName:String
    public let description:String
    public let debugDescription:String

    public init(rawValue: String, caseName: String, debugDescription: String) {
        self.rawValue = rawValue
        self.caseName = caseName
        description = rawValue
        self.debugDescription = debugDescription
    }
}