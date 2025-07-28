
import DestinyBlueprint

// MARK: Parse
extension HTTPMediaType {
    @inlinable
    public static func parse(memberName: String) -> Self? {
        if let v = parseApplication(memberName: memberName) { return v }
        if let v = parseFont(memberName: memberName) { return v }
        if let v = parseHaptics(memberName: memberName) { return v }
        if let v = parseImage(memberName: memberName) { return v }
        if let v = parseMessage(memberName: memberName) { return v }
        if let v = parseModel(memberName: memberName) { return v }
        if let v = parseMultipart(memberName: memberName) { return v }
        if let v = parseText(memberName: memberName) { return v }
        if let v = parseVideo(memberName: memberName) { return v }
        return nil
    }
    @inlinable
    public static func parse(fileExtension: String) -> Self? {
        if let v = parseApplication(fileExtension: fileExtension) { return v }
        if let v = parseFont(fileExtension: fileExtension) { return v }
        if let v = parseHaptics(fileExtension: fileExtension) { return v }
        if let v = parseImage(fileExtension: fileExtension) { return v }
        if let v = parseMessage(fileExtension: fileExtension) { return v }
        if let v = parseModel(fileExtension: fileExtension) { return v }
        if let v = parseMultipart(fileExtension: fileExtension) { return v }
        if let v = parseText(fileExtension: fileExtension) { return v }
        if let v = parseVideo(fileExtension: fileExtension) { return v }
        return nil
    }
}