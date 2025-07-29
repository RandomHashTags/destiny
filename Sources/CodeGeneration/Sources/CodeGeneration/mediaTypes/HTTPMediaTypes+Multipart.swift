
extension HTTPMediaTypes {
    static var multipartMediaTypes: [HTTPMediaType] {
        [
            .init("alternative", ""),
            .init("appledouble", ""),
            .init("byteranges", ""),
            .init("digest", ""),
            .init("encrypted", ""),
            .init("example", ""),
            .init("formData", "form-data"),
            .init("headerSet", "header-set"),
            .init("mixed", ""),
            .init("multilingual", ""),
            .init("parallel", ""),
            .init("related", ""),
            .init("report", ""),
            .init("signed", ""),
            .init("medPlus", "vnd.bint.med-plus"),
            .init("voiceMessage", "voice-message"),
            .init("xMixedReplace", "x-mixed-replace")
        ]
    }
}