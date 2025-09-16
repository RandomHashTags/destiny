
import DestinyDefaults

extension HTTPMediaTypeVideo: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "_1dInterleavedParityfec": self = ._1dInterleavedParityfec
        case "_3gpp": self = ._3gpp
        case "_3gpp2": self = ._3gpp2
        case "_3gppTT": self = ._3gppTT
        case "av1": self = .av1
        case "bmpeg": self = .bmpeg
        case "bt656": self = .bt656
        case "celB": self = .celB
        case "dv": self = .dv
        case "encaprtp": self = .encaprtp
        case "enc": self = .enc
        case "example": self = .example
        case "ffv1": self = .ffv1
        case "flexfec": self = .flexfec
        case "h261": self = .h261
        case "h263": self = .h263
        case "h263_2000": self = .h263_2000
        case "h264": self = .h264
        case "h264RCDO": self = .h264RCDO
        case "h264SVC": self = .h264SVC
        case "h265": self = .h265
        case "h266": self = .h266
        case "isoSegment": self = .isoSegment
        case "jpeg": self = .jpeg
        case "jpeg2000": self = .jpeg2000
        case "jxsv": self = .jxsv
        case "matroska": self = .matroska
        case "matroska3d": self = .matroska3d
        case "mj2": self = .mj2
        case "mp1s": self = .mp1s
        case "mp2p": self = .mp2p
        case "mp2t": self = .mp2t
        case "mp4": self = .mp4
        case "mp4VES": self = .mp4VES
        case "mpv": self = .mpv
        case "mpeg": self = .mpeg
        case "mpeg4Generic": self = .mpeg4Generic
        case "nv": self = .nv
        case "ogg": self = .ogg
        case "parityfec": self = .parityfec
        case "pointer": self = .pointer
        case "quicktime": self = .quicktime
        case "raptorfec": self = .raptorfec
        case "raw": self = .raw
        case "rptEncAescm128": self = .rptEncAescm128
        case "rtploopback": self = .rtploopback
        case "rtx": self = .rtx
        case "scip": self = .scip
        case "smpte291": self = .smpte291
        case "smpte292m": self = .smpte292m
        case "ulpfec": self = .ulpfec
        case "vc1": self = .vc1
        case "vc2": self = .vc2
        case "cctv": self = .cctv
        case "deceHD": self = .deceHD
        case "deceMobile": self = .deceMobile
        case "deceMP4": self = .deceMP4
        case "decePD": self = .decePD
        case "deceSD": self = .deceSD
        case "deceVideo": self = .deceVideo
        case "directvMPEG": self = .directvMPEG
        case "directvMPEGTTS": self = .directvMPEGTTS
        case "dlnaMpegTTS": self = .dlnaMpegTTS
        case "dvbFile": self = .dvbFile
        case "fvt": self = .fvt
        case "hnsVideo": self = .hnsVideo
        case "iptvforum1dparityfec1010": self = .iptvforum1dparityfec1010
        case "iptvforum1dparityfec2005": self = .iptvforum1dparityfec2005
        case "iptvforum2dparityfec1010": self = .iptvforum2dparityfec1010
        case "iptvforum2dparityfec2005": self = .iptvforum2dparityfec2005
        case "iptvforumTTSAVC": self = .iptvforumTTSAVC
        case "iptvforumTTSMPEG2": self = .iptvforumTTSMPEG2
        case "motorolaVideo": self = .motorolaVideo
        case "motorolaVideop": self = .motorolaVideop
        case "mpegurl": self = .mpegurl
        case "pyv": self = .pyv
        case "nokiaInterleavedMultimedia": self = .nokiaInterleavedMultimedia
        case "nokiaMP4VR": self = .nokiaMP4VR
        case "nokiaVideoVOIP": self = .nokiaVideoVOIP
        case "objectvideo": self = .objectvideo
        case "radgamettoolsBink": self = .radgamettoolsBink
        case "radgamettoolsSmacker": self = .radgamettoolsSmacker
        case "sealedMPEG1": self = .sealedMPEG1
        case "sealedMPEG4": self = .sealedMPEG4
        case "sealedSWF": self = .sealedSWF
        case "sealedMediaSoftSealMOV": self = .sealedMediaSoftSealMOV
        case "uvvuMP4": self = .uvvuMP4
        case "youtubeYT": self = .youtubeYT
        case "vivo": self = .vivo
        case "vp8": self = .vp8
        case "vp9": self = .vp9
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case ._1dInterleavedParityfec: "_1dInterleavedParityfec"
        case ._3gpp: "_3gpp"
        case ._3gpp2: "_3gpp2"
        case ._3gppTT: "_3gppTT"
        case .av1: "av1"
        case .bmpeg: "bmpeg"
        case .bt656: "bt656"
        case .celB: "celB"
        case .dv: "dv"
        case .encaprtp: "encaprtp"
        case .enc: "enc"
        case .example: "example"
        case .ffv1: "ffv1"
        case .flexfec: "flexfec"
        case .h261: "h261"
        case .h263: "h263"
        case .h263_2000: "h263_2000"
        case .h264: "h264"
        case .h264RCDO: "h264RCDO"
        case .h264SVC: "h264SVC"
        case .h265: "h265"
        case .h266: "h266"
        case .isoSegment: "isoSegment"
        case .jpeg: "jpeg"
        case .jpeg2000: "jpeg2000"
        case .jxsv: "jxsv"
        case .matroska: "matroska"
        case .matroska3d: "matroska3d"
        case .mj2: "mj2"
        case .mp1s: "mp1s"
        case .mp2p: "mp2p"
        case .mp2t: "mp2t"
        case .mp4: "mp4"
        case .mp4VES: "mp4VES"
        case .mpv: "mpv"
        case .mpeg: "mpeg"
        case .mpeg4Generic: "mpeg4Generic"
        case .nv: "nv"
        case .ogg: "ogg"
        case .parityfec: "parityfec"
        case .pointer: "pointer"
        case .quicktime: "quicktime"
        case .raptorfec: "raptorfec"
        case .raw: "raw"
        case .rptEncAescm128: "rptEncAescm128"
        case .rtploopback: "rtploopback"
        case .rtx: "rtx"
        case .scip: "scip"
        case .smpte291: "smpte291"
        case .smpte292m: "smpte292m"
        case .ulpfec: "ulpfec"
        case .vc1: "vc1"
        case .vc2: "vc2"
        case .cctv: "cctv"
        case .deceHD: "deceHD"
        case .deceMobile: "deceMobile"
        case .deceMP4: "deceMP4"
        case .decePD: "decePD"
        case .deceSD: "deceSD"
        case .deceVideo: "deceVideo"
        case .directvMPEG: "directvMPEG"
        case .directvMPEGTTS: "directvMPEGTTS"
        case .dlnaMpegTTS: "dlnaMpegTTS"
        case .dvbFile: "dvbFile"
        case .fvt: "fvt"
        case .hnsVideo: "hnsVideo"
        case .iptvforum1dparityfec1010: "iptvforum1dparityfec1010"
        case .iptvforum1dparityfec2005: "iptvforum1dparityfec2005"
        case .iptvforum2dparityfec1010: "iptvforum2dparityfec1010"
        case .iptvforum2dparityfec2005: "iptvforum2dparityfec2005"
        case .iptvforumTTSAVC: "iptvforumTTSAVC"
        case .iptvforumTTSMPEG2: "iptvforumTTSMPEG2"
        case .motorolaVideo: "motorolaVideo"
        case .motorolaVideop: "motorolaVideop"
        case .mpegurl: "mpegurl"
        case .pyv: "pyv"
        case .nokiaInterleavedMultimedia: "nokiaInterleavedMultimedia"
        case .nokiaMP4VR: "nokiaMP4VR"
        case .nokiaVideoVOIP: "nokiaVideoVOIP"
        case .objectvideo: "objectvideo"
        case .radgamettoolsBink: "radgamettoolsBink"
        case .radgamettoolsSmacker: "radgamettoolsSmacker"
        case .sealedMPEG1: "sealedMPEG1"
        case .sealedMPEG4: "sealedMPEG4"
        case .sealedSWF: "sealedSWF"
        case .sealedMediaSoftSealMOV: "sealedMediaSoftSealMOV"
        case .uvvuMP4: "uvvuMP4"
        case .youtubeYT: "youtubeYT"
        case .vivo: "vivo"
        case .vp8: "vp8"
        case .vp9: "vp9"
        }
    }
}