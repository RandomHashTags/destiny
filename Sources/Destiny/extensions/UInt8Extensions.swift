
// https://www.ascii-code.com/
extension UInt8 {
    // MARK: symbols
    /// ASCII code for the `\n` control character.
    @inlinable
    @inline(__always)
    public static var lineFeed: Self { 10 }

    /// ASCII code for the `\r` control character.
    @inlinable
    @inline(__always)
    public static var carriageReturn: Self { 13 }

    /// ASCII code for the ` ` printable character.
    @inlinable
    @inline(__always)
    public static var space: Self { 32 }

    /// ASCII code for the `!` printable character.
    @inlinable
    @inline(__always)
    public static var exclamationMark: Self { 33 }

    /// ASCII code for the `"` printable character.
    @inlinable
    @inline(__always)
    public static var quotation: Self { 34 }

    /// ASCII code for the `#` printable character.
    @inlinable
    @inline(__always)
    public static var numberSign: Self { 35 }

    /// ASCII code for the `$` printable character.
    @inlinable
    @inline(__always)
    public static var dollarSign: Self { 36 }

    /// ASCII code for the `%` printable character.
    @inlinable
    @inline(__always)
    public static var percent: Self { 37 }

    /// ASCII code for the `&` printable character.
    @inlinable
    @inline(__always)
    public static var ampersand: Self { 38 }

    /// ASCII code for the `'` printable character.
    @inlinable
    @inline(__always)
    public static var apostrophe: Self { 39 }

    /// ASCII code for the `(` printable character.
    @inlinable
    @inline(__always)
    public static var openingParenthesis: Self { 40 }

    /// ASCII code for the `)` printable character.
    @inlinable
    @inline(__always)
    public static var closingParenthesis: Self { 41 }

    /// ASCII code for the `*` printable character.
    @inlinable
    @inline(__always)
    public static var asterisk: Self { 42 }

    /// ASCII code for the `+` printable character.
    @inlinable
    @inline(__always)
    public static var plus: Self { 43 }

    /// ASCII code for the `,` printable character.
    @inlinable
    @inline(__always)
    public static var comma: Self { 44 }

    /// ASCII code for the `-` printable character.
    @inlinable
    @inline(__always)
    public static var subtract: Self { 45 }

    /// ASCII code for the `.` printable character.
    @inlinable
    @inline(__always)
    public static var period: Self { 46 }

    /// ASCII code for the `/` printable character.
    @inlinable
    @inline(__always)
    public static var forwardSlash: Self { 47 }

    /// ASCII code for the `:` printable character.
    @inlinable
    @inline(__always)
    public static var colon: Self { 58 }

    /// ASCII code for the `;` printable character.
    @inlinable
    @inline(__always)
    public static var semicolon: Self { 59 }

    /// ASCII code for the `<` printable character.
    @inlinable
    @inline(__always)
    public static var lessThan: Self { 60 }

    /// ASCII code for the `=` printable character.
    @inlinable
    @inline(__always)
    public static var equal: Self { 61 }

    /// ASCII code for the `>` printable character.
    @inlinable
    @inline(__always)
    public static var greaterThan: Self { 62 }

    /// ASCII code for the `?` printable character.
    @inlinable
    @inline(__always)
    public static var questionMark: Self { 63 }

    /// ASCII code for the `@` printable character.
    @inlinable
    @inline(__always)
    public static var atSign: Self { 64 }

    /// ASCII code for the `[` printable character.
    @inlinable
    @inline(__always)
    public static var openingBracket: Self { 91 }

    /// ASCII code for the `\` printable character.
    @inlinable
    @inline(__always)
    public static var backslash: Self { 92 }

    /// ASCII code for the `]` printable character.
    @inlinable
    @inline(__always)
    public static var closingBracket: Self { 93 }

    /// ASCII code for the `^` printable character.
    @inlinable
    @inline(__always)
    public static var caret: Self { 94 }

    /// ASCII code for the `_` printable character.
    @inlinable
    @inline(__always)
    public static var underscore: Self { 95 }

    /// ASCII code for the "`" printable character (96).
    @inlinable
    @inline(__always)
    public static var graveAccent: Self { 96 }

    /// ASCII code for the `{` printable character.
    @inlinable
    @inline(__always)
    public static var openingBrace: Self { 123 }

    /// ASCII code for the `|` printable character.
    @inlinable
    @inline(__always)
    public static var verticalBar: Self { 124 }
    
    /// ASCII code for the `}` printable character.
    @inlinable
    @inline(__always)
    public static var closingBrace: Self { 125 }
    
    /// ASCII code for the `~` printable character.
    @inlinable
    @inline(__always)
    public static var tilde: Self { 126 }

    /// ASCII code for the `€` printable character.
    @inlinable
    @inline(__always)
    public static var euroSign: Self { 128 }

    /// ASCII code for the `£` printable character.
    @inlinable
    @inline(__always)
    public static var poundSign: Self { 163 }


    // MARK: Numbers
    /// ASCII code for the `0` printable character.
    @inlinable
    @inline(__always)
    public static var zero: Self { 48 }

    /// ASCII code for the `1` printable character.
    @inlinable
    @inline(__always)
    public static var one: Self { 49 }

    /// ASCII code for the `2` printable character.
    @inlinable
    @inline(__always)
    public static var two: Self { 50 }

    /// ASCII code for the `3` printable character.
    @inlinable
    @inline(__always)
    public static var three: Self { 51 }

    /// ASCII code for the `4` printable character.
    @inlinable
    @inline(__always)
    public static var four: Self { 52 }

    /// ASCII code for the `5` printable character.
    @inlinable
    @inline(__always)
    public static var five: Self { 53 }

    /// ASCII code for the `6` printable character.
    @inlinable
    @inline(__always)
    public static var six: Self { 54 }

    /// ASCII code for the `7` printable character.
    @inlinable
    @inline(__always)
    public static var seven: Self { 55 }

    /// ASCII code for the `8` printable character.
    @inlinable
    @inline(__always)
    public static var eight: Self { 56 }

    /// ASCII code for the `9` printable character.
    @inlinable
    @inline(__always)
    public static var nine: Self { 57 }


    // MARK: letters
    /// ASCII code for the `A` printable character.
    @inlinable
    @inline(__always)
    public static var A: Self { 65 }

    /// ASCII code for the `B` printable character.
    @inlinable
    @inline(__always)
    public static var B: Self { 66 }

    /// ASCII code for the `C` printable character.
    @inlinable
    @inline(__always)
    public static var C: Self { 67 }

    /// ASCII code for the `D` printable character.
    @inlinable
    @inline(__always)
    public static var D: Self { 68 }

    /// ASCII code for the `E` printable character.
    @inlinable
    @inline(__always)
    public static var E: Self { 69 }

    /// ASCII code for the `F` printable character.
    @inlinable
    @inline(__always)
    public static var F: Self { 70 }

    /// ASCII code for the `G` printable character.
    @inlinable
    @inline(__always)
    public static var G: Self { 71 }

    /// ASCII code for the `H` printable character.
    @inlinable
    @inline(__always)
    public static var H: Self { 72 }

    /// ASCII code for the `I` printable character.
    @inlinable
    @inline(__always)
    public static var I: Self { 73 }

    /// ASCII code for the `J` printable character.
    @inlinable
    @inline(__always)
    public static var J: Self { 74 }

    /// ASCII code for the `K` printable character.
    @inlinable
    @inline(__always)
    public static var K: Self { 75 }

    /// ASCII code for the `L` printable character.
    @inlinable
    @inline(__always)
    public static var L: Self { 76 }

    /// ASCII code for the `M` printable character.
    @inlinable
    @inline(__always)
    public static var M: Self { 77 }

    /// ASCII code for the `N` printable character.
    @inlinable
    @inline(__always)
    public static var N: Self { 78 }

    /// ASCII code for the `O` printable character.
    @inlinable
    @inline(__always)
    public static var O: Self { 79 }

    /// ASCII code for the `P` printable character.
    @inlinable
    @inline(__always)
    public static var P: Self { 80 }

    /// ASCII code for the `Q` printable character.
    @inlinable
    @inline(__always)
    public static var Q: Self { 81 }

    /// ASCII code for the `R` printable character.
    @inlinable
    @inline(__always)
    public static var R: Self { 82 }

    /// ASCII code for the `S` printable character.
    @inlinable
    @inline(__always)
    public static var S: Self { 83 }

    /// ASCII code for the `T` printable character.
    @inlinable
    @inline(__always)
    public static var T: Self { 84 }

    /// ASCII code for the `U` printable character.
    @inlinable
    @inline(__always)
    public static var U: Self { 85 }

    /// ASCII code for the `V` printable character.
    @inlinable
    @inline(__always)
    public static var V: Self { 86 }

    /// ASCII code for the `W` printable character.
    @inlinable
    @inline(__always)
    public static var W: Self { 87 }

    /// ASCII code for the `X` printable character.
    @inlinable
    @inline(__always)
    public static var X: Self { 88 }

    /// ASCII code for the `Y` printable character.
    @inlinable
    @inline(__always)
    public static var Y: Self { 89 }

    /// ASCII code for the `Z` printable character.
    @inlinable
    @inline(__always)
    public static var Z: Self { 90 }


    /// ASCII code for the `a` printable character.
    @inlinable
    @inline(__always)
    public static var a: Self { 97 }

    /// ASCII code for the `b` printable character.
    @inlinable
    @inline(__always)
    public static var b: Self { 98 }

    /// ASCII code for the `c` printable character.
    @inlinable
    @inline(__always)
    public static var c: Self { 99 }

    /// ASCII code for the `d` printable character.
    @inlinable
    @inline(__always)
    public static var d: Self { 100 }

    /// ASCII code for the `e` printable character.
    @inlinable
    @inline(__always)
    public static var e: Self { 101 }

    /// ASCII code for the `f` printable character.
    @inlinable
    @inline(__always)
    public static var f: Self { 102 }

    /// ASCII code for the `g` printable character.
    @inlinable
    @inline(__always)
    public static var g: Self { 103 }

    /// ASCII code for the `h` printable character.
    @inlinable
    @inline(__always)
    public static var h: Self { 104 }

    /// ASCII code for the `i` printable character.
    @inlinable
    @inline(__always)
    public static var i: Self { 105 }

    /// ASCII code for the `j` printable character.
    @inlinable
    @inline(__always)
    public static var j: Self { 106 }

    /// ASCII code for the `k` printable character.
    @inlinable
    @inline(__always)
    public static var k: Self { 107 }

    /// ASCII code for the `l` printable character.
    @inlinable
    @inline(__always)
    public static var l: Self { 108 }

    /// ASCII code for the `m` printable character.
    @inlinable
    @inline(__always)
    public static var m: Self { 109 }

    /// ASCII code for the `n` printable character.
    @inlinable
    @inline(__always)
    public static var n: Self { 110 }

    /// ASCII code for the `o` printable character.
    @inlinable
    @inline(__always)
    public static var o: Self { 111 }

    /// ASCII code for the `p` printable character.
    @inlinable
    @inline(__always)
    public static var p: Self { 112 }

    /// ASCII code for the `q` printable character.
    @inlinable
    @inline(__always)
    public static var q: Self { 113 }

    /// ASCII code for the `r` printable character.
    @inlinable
    @inline(__always)
    public static var r: Self { 114 }

    /// ASCII code for the `s` printable character.
    @inlinable
    @inline(__always)
    public static var s: Self { 115 }

    /// ASCII code for the `t` printable character.
    @inlinable
    @inline(__always)
    public static var t: Self { 116 }

    /// ASCII code for the `u` printable character.
    @inlinable
    @inline(__always)
    public static var u: Self { 117 }

    /// ASCII code for the `v` printable character.
    @inlinable
    @inline(__always)
    public static var v: Self { 118 }

    /// ASCII code for the `w` printable character.
    @inlinable
    @inline(__always)
    public static var w: Self { 119 }

    /// ASCII code for the `x` printable character.
    @inlinable
    @inline(__always)
    public static var x: Self { 120 }

    /// ASCII code for the `y` printable character.
    @inlinable
    @inline(__always)
    public static var y: Self { 121 }

    /// ASCII code for the `z` printable character.
    @inlinable
    @inline(__always)
    public static var z: Self { 122 }
}