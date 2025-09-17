
import HTTPMediaTypes

extension HTTPMediaTypeModel: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "_3mf": self = ._3mf
        case "e57": self = .e57
        case "example": self = .example
        case "gltfBinary": self = .gltfBinary
        case "gltfJSON": self = .gltfJSON
        case "jt": self = .jt
        case "iges": self = .iges
        case "mesh": self = .mesh
        case "mtl": self = .mtl
        case "obj": self = .obj
        case "prc": self = .prc
        case "step": self = .step
        case "stepXML": self = .stepXML
        case "stepZip": self = .stepZip
        case "stepXMLZip": self = .stepXMLZip
        case "stl": self = .stl
        case "u3d": self = .u3d
        case "bary": self = .bary
        case "cld": self = .cld
        case "colladaXML": self = .colladaXML
        case "dwf": self = .dwf
        case "_3dm": self = ._3dm
        case "_3dml": self = ._3dml
        case "gdl": self = .gdl
        case "gsGdl": self = .gsGdl
        case "gtw": self = .gtw
        case "momlXML": self = .momlXML
        case "mts": self = .mts
        case "opengex": self = .opengex
        case "parasolidTransmitBinary": self = .parasolidTransmitBinary
        case "parasolidTransmitText": self = .parasolidTransmitText
        case "pythaPyox": self = .pythaPyox
        case "rosetteAnnotatedDataModel": self = .rosetteAnnotatedDataModel
        case "sapVds": self = .sapVds
        case "usda": self = .usda
        case "usdz": self = .usdz
        case "bsp": self = .bsp
        case "vtu": self = .vtu
        case "vrml": self = .vrml
        case "x3dv": self = .x3dv
        case "x3db": self = .x3db
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case ._3mf: "_3mf"
        case .e57: "e57"
        case .example: "example"
        case .gltfBinary: "gltfBinary"
        case .gltfJSON: "gltfJSON"
        case .jt: "jt"
        case .iges: "iges"
        case .mesh: "mesh"
        case .mtl: "mtl"
        case .obj: "obj"
        case .prc: "prc"
        case .step: "step"
        case .stepXML: "stepXML"
        case .stepZip: "stepZip"
        case .stepXMLZip: "stepXMLZip"
        case .stl: "stl"
        case .u3d: "u3d"
        case .bary: "bary"
        case .cld: "cld"
        case .colladaXML: "colladaXML"
        case .dwf: "dwf"
        case ._3dm: "_3dm"
        case ._3dml: "_3dml"
        case .gdl: "gdl"
        case .gsGdl: "gsGdl"
        case .gtw: "gtw"
        case .momlXML: "momlXML"
        case .mts: "mts"
        case .opengex: "opengex"
        case .parasolidTransmitBinary: "parasolidTransmitBinary"
        case .parasolidTransmitText: "parasolidTransmitText"
        case .pythaPyox: "pythaPyox"
        case .rosetteAnnotatedDataModel: "rosetteAnnotatedDataModel"
        case .sapVds: "sapVds"
        case .usda: "usda"
        case .usdz: "usdz"
        case .bsp: "bsp"
        case .vtu: "vtu"
        case .vrml: "vrml"
        case .x3dv: "x3dv"
        case .x3db: "x3db"
        }
    }
}