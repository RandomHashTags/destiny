
extension HTTPMediaTypes {
    static var audioMediaTypes: [HTTPMediaType] {
        [
            .init("aac", "", fileExtensions: ["aac"]),

            .init("mp4", "", fileExtensions: ["mp4"]),
            .init("mpeg", "", fileExtensions: ["mpeg"]),

            .init("ogg", "", fileExtensions: ["ogg"])
        ]
    }
}