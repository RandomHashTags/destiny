
import DestinyBlueprint

public enum HTTPMediaTypeImage: HTTPMediaTypeProtocol {
    case aces
    case apng
    case avci
    case avcs
    case avif
    case bmp
    case cgm
    case dicomRLE
    case dpx
    case emf
    case example
    case fits
    case g3fax
    case gif
    case heic
    case heicSequence
    case heif
    case heifSequence
    case hej2k
    case ief
    case j2c
    case jls
    case jp2
    case jpeg
    case jph
    case jphc
    case jpm
    case jpx
    case jxl
    case jxr
    case jxrA
    case jxrS
    case jxs
    case jxsc
    case jxsi
    case jxss
    case ktx
    case ktx2
    case naplps
    case png
    case prsBTIF
    case prsPTI
    case pwgRaster
    case svgXML
    case t38
    case tiff
    case tiffFX
    case psd
    case airzipAcceleratorAZV
    case cnsINF2
    case deceGraphic
    case djvu
    case dwg
    case dxf
    case dvbSubtitle
    case fastbidsheet
    case fpx
    case fst
    case fujixeroxEdmicsMMR
    case fujixeroxEdmicsRLC
    case globalGraphicsPGB
    case microsoftIcon
    case mix
    case msModi
    case mozillaAPNG
    case netFPX
    case pcoB16
    case radiance
    case sealedPNG
    case sealedMediaSoftSealGIF
    case sealedMediaSoftSealJPG
    case svf
    case tencentTap
    case vtf
    case wapWBMP
    case xiff
    case zbrushPCX
    case webp
    case wmf

    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        case "gif": self = .gif
        case "jpeg", "jpg": self = .jpeg
        case "png": self = .png
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var type: String {
        "image"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case .aces: "aces"
        case .apng: "apng"
        case .avci: "avci"
        case .avcs: "avcs"
        case .avif: "avif"
        case .bmp: "bmp"
        case .cgm: "cgm"
        case .dicomRLE: "dicom-rle"
        case .dpx: "dpx"
        case .emf: "emf"
        case .example: "example"
        case .fits: "fits"
        case .g3fax: "g3fax"
        case .gif: "gif"
        case .heic: "heic"
        case .heicSequence: "heic-sequence"
        case .heif: "heif"
        case .heifSequence: "heif-sequence"
        case .hej2k: "hej2k"
        case .ief: "ief"
        case .j2c: "j2c"
        case .jls: "jls"
        case .jp2: "jp2"
        case .jpeg: "jpeg"
        case .jph: "jph"
        case .jphc: "jphc"
        case .jpm: "jpm"
        case .jpx: "jpx"
        case .jxl: "jxl"
        case .jxr: "jxr"
        case .jxrA: "jxrA"
        case .jxrS: "jxrS"
        case .jxs: "jxs"
        case .jxsc: "jxsc"
        case .jxsi: "jxsi"
        case .jxss: "jxss"
        case .ktx: "ktx"
        case .ktx2: "ktx2"
        case .naplps: "naplps"
        case .png: "png"
        case .prsBTIF: "prs.btif"
        case .prsPTI: "prs.bti"
        case .pwgRaster: "pwg-raster"
        case .svgXML: "svg+xml"
        case .t38: "t38"
        case .tiff: "tiff"
        case .tiffFX: "tiff-fx"
        case .psd: "vnd.adobe.photoshop"
        case .airzipAcceleratorAZV: "cnd.airzip.accelerator.azv"
        case .cnsINF2: "vnd.cns.inf2"
        case .deceGraphic: "vnd.dece.graphic"
        case .djvu: "vnd.djvu"
        case .dwg: "vnd.dwg"
        case .dxf: "vnd.dxf"
        case .dvbSubtitle: "vnd.dvb.subtitle"
        case .fastbidsheet: "vnd.fastbidsheet"
        case .fpx: "vnd.fpx"
        case .fst: "vnd.fst"
        case .fujixeroxEdmicsMMR: "vnd.fujixerox.edmics-mmr"
        case .fujixeroxEdmicsRLC: "vnd.fujixerox.edmics-rlc"
        case .globalGraphicsPGB: "vnd.globalgraphics.pgb"
        case .microsoftIcon: "vnd.microsoft.icon"
        case .mix: "vnd.mix"
        case .msModi: "vnd.ms-modi"
        case .mozillaAPNG: "vnd.mozilla.apng"
        case .netFPX: "vnd.net-fpx"
        case .pcoB16: "vnd.pco.b16"
        case .radiance: "vnd.radiance"
        case .sealedPNG: "vnd.sealed.png"
        case .sealedMediaSoftSealGIF: "vnd.sealedmedia.softseal.gif"
        case .sealedMediaSoftSealJPG: "vnd.sealedmedia.softseal.jpg"
        case .svf: "vnd.svf"
        case .tencentTap: "vnd.tencent.tap"
        case .vtf: "vnd.valve.source.texture"
        case .wapWBMP: "vnd.wap.wbmp"
        case .xiff: "vnd.xiff"
        case .zbrushPCX: "vnd.zbrush.pcx"
        case .webp: "webp"
        case .wmf: "wmf"
        }
    }
}