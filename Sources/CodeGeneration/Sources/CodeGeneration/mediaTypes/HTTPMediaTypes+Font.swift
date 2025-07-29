
extension HTTPMediaTypes {
    static var fontMediaTypes: [HTTPMediaType] {
        [
            .init("collection", ""),
            .init("otf", ""),
            .init("sfnt", ""),
            .init("ttf", ""),
            .init("woff", ""),
            .init("woff2", "")
        ]
    }
}