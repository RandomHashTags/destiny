
struct HTTPMediaType {
    let subType:String
    let value:String
    let fileExtensions:[String]

    init(
        _ subType: String,
        _ value: String,
        fileExtensions: [String] = []
    ) {
        self.subType = subType
        self.value = value
        self.fileExtensions = fileExtensions
    }
}