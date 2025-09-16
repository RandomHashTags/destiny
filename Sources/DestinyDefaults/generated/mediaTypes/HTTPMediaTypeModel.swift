
import DestinyBlueprint

public enum HTTPMediaTypeModel: HTTPMediaTypeProtocol {
    case _3mf
    case e57
    case example
    case gltfBinary
    case gltfJSON
    case jt
    case iges
    case mesh
    case mtl
    case obj
    case prc
    case step
    case stepXML
    case stepZip
    case stepXMLZip
    case stl
    case u3d
    case bary
    case cld
    case colladaXML
    case dwf
    case _3dm
    case _3dml
    case gdl
    case gsGdl
    case gtw
    case momlXML
    case mts
    case opengex
    case parasolidTransmitBinary
    case parasolidTransmitText
    case pythaPyox
    case rosetteAnnotatedDataModel
    case sapVds
    case usda
    case usdz
    case bsp
    case vtu
    case vrml
    case x3dv
    case x3db

    #if Inlinable
    @inlinable
    #endif
    public var type: String {
        "model"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case ._3mf: "3mf"
        case .e57: "e57"
        case .example: "example"
        case .gltfBinary: "gltf-binary"
        case .gltfJSON: "gltf+json"
        case .jt: "JT"
        case .iges: "iges"
        case .mesh: "mesh"
        case .mtl: "mtl"
        case .obj: "obj"
        case .prc: "prc"
        case .step: "step"
        case .stepXML: "step+xml"
        case .stepZip: "step+zip"
        case .stepXMLZip: "step-xml+zip"
        case .stl: "stl"
        case .u3d: "u3d"
        case .bary: "vnd.bary"
        case .cld: "vnd.cld"
        case .colladaXML: "vnd.collada+xml"
        case .dwf: "vnd.dwf"
        case ._3dm: "vnd.flatland.3dml"
        case ._3dml: "vnd.flatland.3dml"
        case .gdl: "vnd.gld"
        case .gsGdl: "vnd.gs-gdl"
        case .gtw: "vnd.gtw"
        case .momlXML: "vnd.moml+xml"
        case .mts: "vnd.mts"
        case .opengex: "vnd.opengex"
        case .parasolidTransmitBinary: "vnd.parasolid.transmit.binary"
        case .parasolidTransmitText: "vnd.parasolid.transmit.text"
        case .pythaPyox: "vnd.pytha.pyox"
        case .rosetteAnnotatedDataModel: "vnd.rosette.annotated-data-model"
        case .sapVds: "vnd.sap.vds"
        case .usda: "vnd.usda"
        case .usdz: "vnd.usdz+zip"
        case .bsp: "vnd.valve.source.compiled-map"
        case .vtu: "vnd.vtu"
        case .vrml: "vrml"
        case .x3dv: "x3d-vrml"
        case .x3db: "x3d+fastinfoset"
        }
    }
}