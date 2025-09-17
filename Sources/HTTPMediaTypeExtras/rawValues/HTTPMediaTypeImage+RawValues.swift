
import HTTPMediaTypes

extension HTTPMediaTypeImage: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "aces": self = .aces
        case "apng": self = .apng
        case "avci": self = .avci
        case "avcs": self = .avcs
        case "avif": self = .avif
        case "bmp": self = .bmp
        case "cgm": self = .cgm
        case "dicomRLE": self = .dicomRLE
        case "dpx": self = .dpx
        case "emf": self = .emf
        case "example": self = .example
        case "fits": self = .fits
        case "g3fax": self = .g3fax
        case "gif": self = .gif
        case "heic": self = .heic
        case "heicSequence": self = .heicSequence
        case "heif": self = .heif
        case "heifSequence": self = .heifSequence
        case "hej2k": self = .hej2k
        case "ief": self = .ief
        case "j2c": self = .j2c
        case "jls": self = .jls
        case "jp2": self = .jp2
        case "jpeg": self = .jpeg
        case "jph": self = .jph
        case "jphc": self = .jphc
        case "jpm": self = .jpm
        case "jpx": self = .jpx
        case "jxl": self = .jxl
        case "jxr": self = .jxr
        case "jxrA": self = .jxrA
        case "jxrS": self = .jxrS
        case "jxs": self = .jxs
        case "jxsc": self = .jxsc
        case "jxsi": self = .jxsi
        case "jxss": self = .jxss
        case "ktx": self = .ktx
        case "ktx2": self = .ktx2
        case "naplps": self = .naplps
        case "png": self = .png
        case "prsBTIF": self = .prsBTIF
        case "prsPTI": self = .prsPTI
        case "pwgRaster": self = .pwgRaster
        case "svgXML": self = .svgXML
        case "t38": self = .t38
        case "tiff": self = .tiff
        case "tiffFX": self = .tiffFX
        case "psd": self = .psd
        case "airzipAcceleratorAZV": self = .airzipAcceleratorAZV
        case "cnsINF2": self = .cnsINF2
        case "deceGraphic": self = .deceGraphic
        case "djvu": self = .djvu
        case "dwg": self = .dwg
        case "dxf": self = .dxf
        case "dvbSubtitle": self = .dvbSubtitle
        case "fastbidsheet": self = .fastbidsheet
        case "fpx": self = .fpx
        case "fst": self = .fst
        case "fujixeroxEdmicsMMR": self = .fujixeroxEdmicsMMR
        case "fujixeroxEdmicsRLC": self = .fujixeroxEdmicsRLC
        case "globalGraphicsPGB": self = .globalGraphicsPGB
        case "microsoftIcon": self = .microsoftIcon
        case "mix": self = .mix
        case "msModi": self = .msModi
        case "mozillaAPNG": self = .mozillaAPNG
        case "netFPX": self = .netFPX
        case "pcoB16": self = .pcoB16
        case "radiance": self = .radiance
        case "sealedPNG": self = .sealedPNG
        case "sealedMediaSoftSealGIF": self = .sealedMediaSoftSealGIF
        case "sealedMediaSoftSealJPG": self = .sealedMediaSoftSealJPG
        case "svf": self = .svf
        case "tencentTap": self = .tencentTap
        case "vtf": self = .vtf
        case "wapWBMP": self = .wapWBMP
        case "xiff": self = .xiff
        case "zbrushPCX": self = .zbrushPCX
        case "webp": self = .webp
        case "wmf": self = .wmf
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case .aces: "aces"
        case .apng: "apng"
        case .avci: "avci"
        case .avcs: "avcs"
        case .avif: "avif"
        case .bmp: "bmp"
        case .cgm: "cgm"
        case .dicomRLE: "dicomRLE"
        case .dpx: "dpx"
        case .emf: "emf"
        case .example: "example"
        case .fits: "fits"
        case .g3fax: "g3fax"
        case .gif: "gif"
        case .heic: "heic"
        case .heicSequence: "heicSequence"
        case .heif: "heif"
        case .heifSequence: "heifSequence"
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
        case .prsBTIF: "prsBTIF"
        case .prsPTI: "prsPTI"
        case .pwgRaster: "pwgRaster"
        case .svgXML: "svgXML"
        case .t38: "t38"
        case .tiff: "tiff"
        case .tiffFX: "tiffFX"
        case .psd: "psd"
        case .airzipAcceleratorAZV: "airzipAcceleratorAZV"
        case .cnsINF2: "cnsINF2"
        case .deceGraphic: "deceGraphic"
        case .djvu: "djvu"
        case .dwg: "dwg"
        case .dxf: "dxf"
        case .dvbSubtitle: "dvbSubtitle"
        case .fastbidsheet: "fastbidsheet"
        case .fpx: "fpx"
        case .fst: "fst"
        case .fujixeroxEdmicsMMR: "fujixeroxEdmicsMMR"
        case .fujixeroxEdmicsRLC: "fujixeroxEdmicsRLC"
        case .globalGraphicsPGB: "globalGraphicsPGB"
        case .microsoftIcon: "microsoftIcon"
        case .mix: "mix"
        case .msModi: "msModi"
        case .mozillaAPNG: "mozillaAPNG"
        case .netFPX: "netFPX"
        case .pcoB16: "pcoB16"
        case .radiance: "radiance"
        case .sealedPNG: "sealedPNG"
        case .sealedMediaSoftSealGIF: "sealedMediaSoftSealGIF"
        case .sealedMediaSoftSealJPG: "sealedMediaSoftSealJPG"
        case .svf: "svf"
        case .tencentTap: "tencentTap"
        case .vtf: "vtf"
        case .wapWBMP: "wapWBMP"
        case .xiff: "xiff"
        case .zbrushPCX: "zbrushPCX"
        case .webp: "webp"
        case .wmf: "wmf"
        }
    }
}