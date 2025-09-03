
import DestinyBlueprint

public enum HTTPMediaTypeVideo: String, HTTPMediaTypeProtocol {
    case _1dInterleavedParityfec
    case _3gpp
    case _3gpp2
    case _3gppTT
    case av1
    case bmpeg
    case bt656
    case celB
    case dv
    case encaprtp
    case enc
    case example
    case ffv1
    case flexfec
    case h261
    case h263
    case h263_2000
    case h264
    case h264RCDO
    case h264SVC
    case h265
    case h266
    case isoSegment
    case jpeg
    case jpeg2000
    case jxsv
    case matroska
    case matroska3d
    case mj2
    case mp1s
    case mp2p
    case mp2t
    case mp4
    case mp4VES
    case mpv
    case mpeg
    case mpeg4Generic
    case nv
    case ogg
    case parityfec
    case pointer
    case quicktime
    case raptorfec
    case raw
    case rptEncAescm128
    case rtploopback
    case rtx
    case scip
    case smpte291
    case smpte292m
    case ulpfec
    case vc1
    case vc2
    case cctv
    case deceHD
    case deceMobile
    case deceMP4
    case decePD
    case deceSD
    case deceVideo
    case directvMPEG
    case directvMPEGTTS
    case dlnaMpegTTS
    case dvbFile
    case fvt
    case hnsVideo
    case iptvforum1dparityfec1010
    case iptvforum1dparityfec2005
    case iptvforum2dparityfec1010
    case iptvforum2dparityfec2005
    case iptvforumTTSAVC
    case iptvforumTTSMPEG2
    case motorolaVideo
    case motorolaVideop
    case mpegurl
    case pyv
    case nokiaInterleavedMultimedia
    case nokiaMP4VR
    case nokiaVideoVOIP
    case objectvideo
    case radgamettoolsBink
    case radgamettoolsSmacker
    case sealedMPEG1
    case sealedMPEG4
    case sealedSWF
    case sealedMediaSoftSealMOV
    case uvvuMP4
    case youtubeYT
    case vivo
    case vp8
    case vp9

    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        case "av1": self = .av1
        case "mpeg": self = .mpeg
        case "ogg": self = .ogg
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var type: String {
        "video"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case ._1dInterleavedParityfec: "1d-interleaved-parityfec"
        case ._3gpp: "3gpp"
        case ._3gpp2: "3gpp2"
        case ._3gppTT: "3gpp-tt"
        case .av1: "AV1"
        case .bmpeg: "BMPEG"
        case .bt656: "BT656"
        case .celB: "CelB"
        case .dv: "DV"
        case .encaprtp: rawValue
        case .enc: rawValue
        case .example: rawValue
        case .ffv1: "FFV1"
        case .flexfec: rawValue
        case .h261: "H261"
        case .h263: "H263"
        case .h263_2000: "H263-2000"
        case .h264: "h264"
        case .h264RCDO: "H264-RCDO"
        case .h264SVC: "H264SVC"
        case .h265: "H265"
        case .h266: "H266"
        case .isoSegment: "iso.segment"
        case .jpeg: "JPEG"
        case .jpeg2000: rawValue
        case .jxsv: rawValue
        case .matroska: rawValue
        case .matroska3d: "matroska-3d"
        case .mj2: rawValue
        case .mp1s: "MP1S"
        case .mp2p: "MP2P"
        case .mp2t: "MP2T"
        case .mp4: rawValue
        case .mp4VES: "MP4V-ES"
        case .mpv: "MPV"
        case .mpeg: rawValue
        case .mpeg4Generic: "mpeg4-generic"
        case .nv: rawValue
        case .ogg: rawValue
        case .parityfec: rawValue
        case .pointer: rawValue
        case .quicktime: rawValue
        case .raptorfec: rawValue
        case .raw: rawValue
        case .rptEncAescm128: "rtp-enc-aescm128"
        case .rtploopback: rawValue
        case .rtx: rawValue
        case .scip: rawValue
        case .smpte291: rawValue
        case .smpte292m: "SMPTE292M"
        case .ulpfec: rawValue
        case .vc1: rawValue
        case .vc2: rawValue
        case .cctv: "vnd.CCTV"
        case .deceHD: "vnd.dece.hd"
        case .deceMobile: "vnd.dece.mobile"
        case .deceMP4: "vnd.dece.mp4"
        case .decePD: "vnd.dece.pd"
        case .deceSD: "vnd.dece.sd"
        case .deceVideo: "vnd.dece.video"
        case .directvMPEG: "vnd.directv.mpeg"
        case .directvMPEGTTS: "vnd.directv.mpegTTS"
        case .dlnaMpegTTS: "vnd.dlna.mpeg-tts"
        case .dvbFile: "vnd.dvb.file"
        case .fvt: "vnd.fvt"
        case .hnsVideo: "vnd.hns.video"
        case .iptvforum1dparityfec1010: "vnd.iptvforum.1dparityfec-1010"
        case .iptvforum1dparityfec2005: "vnd.iptvforum.1dparityfec-2005"
        case .iptvforum2dparityfec1010: "vnd.iptvforum.2dparityfec-1010"
        case .iptvforum2dparityfec2005: "vnd.iptvforum.2dparityfec-2005"
        case .iptvforumTTSAVC: "vnd.iptvforum.ttsavc"
        case .iptvforumTTSMPEG2: "vnd.iptvforum.ttsmpeg2"
        case .motorolaVideo: "vnd.motorola.video"
        case .motorolaVideop: "vnd.motorola.videop"
        case .mpegurl: "vnd.mpegurl"
        case .pyv: "vnd.ms-playready.media.pyv"
        case .nokiaInterleavedMultimedia: "vnd.nokia.interleaved-multimedia"
        case .nokiaMP4VR: "vnd.nokia.mp4vr"
        case .nokiaVideoVOIP: "vnd.nokia.videovoip"
        case .objectvideo: "vnd.objectvideo"
        case .radgamettoolsBink: "vnd.radgamettools.bink"
        case .radgamettoolsSmacker: "vnd.radgamettools.smacker"
        case .sealedMPEG1: "vnd.sealed.mpeg1"
        case .sealedMPEG4: "vnd.sealed.mpeg4"
        case .sealedSWF: "vnd.sealed.swf"
        case .sealedMediaSoftSealMOV: "vnd.sealedmedia.softseal.mov"
        case .uvvuMP4: "vnd.uvvu.mp4"
        case .youtubeYT: "vnd.youtube.yt"
        case .vivo: "vnd.vivo"
        case .vp8: "VP8"
        case .vp9: "VP9"
        }
    }
}