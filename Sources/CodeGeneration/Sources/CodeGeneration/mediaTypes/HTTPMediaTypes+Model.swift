
extension HTTPMediaTypes {
    static var modelMediaTypes: [HTTPMediaType] {
        [
            .init("_3mf", "3mf"),
            .init("e57", ""),
            .init("example", ""),
            .init("gltfBinary", "gltf-binary"),
            .init("gltfJSON", "gltf+json"),
            .init("jt", "JT"),
            .init("iges", ""),
            .init("mesh", ""),
            .init("mtl", ""),
            .init("obj", ""),
            .init("prc", ""),
            .init("step", ""),
            .init("stepXML", "step+xml"),
            .init("stepZip", "step+zip"),
            .init("stepXMLZip", "step-xml+zip"),
            .init("stl", ""),
            .init("u3d", ""),
            
            .init("bary", "vnd.bary"),
            .init("cld", "vnd.cld"),
            .init("colladaXML", "vnd.collada+xml"),
            .init("dwf", "vnd.dwf"),
            .init("_3dm", "vnd.flatland.3dml"),
            .init("_3dml", "vnd.flatland.3dml"),
            .init("gdl", "vnd.gld"),
            .init("gsGdl", "vnd.gs-gdl"),
            .init("gtw", "vnd.gtw"),
            .init("momlXML", "vnd.moml+xml"),
            .init("mts", "vnd.mts"),
            .init("opengex", "vnd.opengex"),
            .init("parasolidTransmitBinary", "vnd.parasolid.transmit.binary"),
            .init("parasolidTransmitText", "vnd.parasolid.transmit.text"),
            .init("pythaPyox", "vnd.pytha.pyox"),
            .init("rosetteAnnotatedDataModel", "vnd.rosette.annotated-data-model"),
            .init("sapVds", "vnd.sap.vds"),
            .init("usda", "vnd.usda"),
            .init("usdz", "vnd.usdz+zip"),
            .init("bsp", "vnd.valve.source.compiled-map"),
            .init("vtu", "vnd.vtu"),
            .init("vrml", "vrml"),
            .init("x3dv", "x3d-vrml"),
            .init("x3db", "x3d+fastinfoset")
        ]
    }
}