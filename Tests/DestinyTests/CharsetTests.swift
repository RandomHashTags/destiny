
import Destiny
import DestinyMacros
import Testing

@Suite
struct CharsetTests {
    let allCases = [
        Charset.any,
        .basicMultilingualPlane,
        .bocu1,
        .iso8859_5,
        .scsu,
        .ucs2,
        .ucs4,
        .utf8,
        .utf16,
        .utf16be,
        .utf16le,
        .utf32
    ]

    @Test
    func charsetRawRepresentable() {
        for charset in allCases {
            #expect(charset.rawValue == "\(charset)")
            #expect(Charset(rawValue: charset.rawValue) == charset)
        }
    }

    @Test
    func charsetRawNames() {
        #expect(Charset.any.rawName == "*")
        #expect(Charset.basicMultilingualPlane.rawName == "BMP")
        #expect(Charset.bocu1.rawName == "BOCU-1")
        #expect(Charset.iso8859_5.rawName == "ISO-8859-5")
        #expect(Charset.scsu.rawName == "SCSU")
        #expect(Charset.ucs2.rawName == "UCS-2")
        #expect(Charset.ucs4.rawName == "UCS-4")
        #expect(Charset.utf8.rawName == "UTF-8")
        #expect(Charset.utf16.rawName == "UTF-16")
        #expect(Charset.utf16be.rawName == "UTF-16BE")
        #expect(Charset.utf16le.rawName == "UTF-16LE")
        #expect(Charset.utf32.rawName == "UTF-32")
    }
}