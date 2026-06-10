//
//  ManaSymbology.swift
//  Boltstorm
//
//  Maps Scryfall mana-cost tags (e.g. "{R}", "{2}") to glyphs in the bundled
//  "Mana" icon font (Andrew Gioia, SIL OFL). Pure and dependency-free — no
//  networking, no symbology API.
//

import CoreText
import Foundation

enum ManaSymbology {

    /// Token produced by tokenizing a mana-cost / oracle string.
    enum Token: Equatable {
        case text(String)
        case symbol(String) // the tag contents without braces, e.g. "R", "2", "W/U"
    }

    /// PostScript / family name of the bundled font (verified: "Mana").
    static let fontName = "Mana"

    /// Scryfall tag (uppercased, braces stripped) → Mana-font code point.
    /// Code points taken from the Mana project's mana.css. Hybrids ("{W/U}") and
    /// Phyrexian ("{W/P}") have no single glyph in this font and are intentionally
    /// omitted — they fall back to readable text.
    private static let glyphScalars: [String: UInt32] = [
        // Colors
        "W": 0xE600, "U": 0xE601, "B": 0xE602, "R": 0xE603, "G": 0xE604,
        // Generic 0–20
        "0": 0xE605, "1": 0xE606, "2": 0xE607, "3": 0xE608, "4": 0xE609,
        "5": 0xE60A, "6": 0xE60B, "7": 0xE60C, "8": 0xE60D, "9": 0xE60E,
        "10": 0xE60F, "11": 0xE610, "12": 0xE611, "13": 0xE612, "14": 0xE613,
        "15": 0xE614, "16": 0xE62A, "17": 0xE62B, "18": 0xE62C, "19": 0xE62D,
        "20": 0xE62E,
        // Variable
        "X": 0xE615, "Y": 0xE616, "Z": 0xE617,
        // Standalone symbols
        "C": 0xE904, // colorless
        "S": 0xE619, // snow
        "T": 0xE61A, // tap
        "Q": 0xE61B, // untap
        "P": 0xE618, // Phyrexian (generic)
    ]

    /// Returns the Mana-font glyph for a tag, or `nil` if it has no single glyph.
    static func glyph(for tag: String) -> Character? {
        guard let codePoint = glyphScalars[tag.uppercased()],
              let scalar = Unicode.Scalar(codePoint) else {
            return nil
        }
        return Character(scalar)
    }

    /// Splits a string into `.text` and `.symbol` runs by scanning `{...}` groups.
    /// An unclosed `{` is emitted as plain text.
    static func tokens(in text: String) -> [Token] {
        var tokens: [Token] = []
        var pending = ""

        func flushPending() {
            if !pending.isEmpty {
                tokens.append(.text(pending))
                pending = ""
            }
        }

        var index = text.startIndex
        while index < text.endIndex {
            if text[index] == "{",
               let close = text[index...].firstIndex(of: "}") {
                flushPending()
                let inner = text[text.index(after: index)..<close]
                tokens.append(.symbol(String(inner)))
                index = text.index(after: close)
            } else {
                pending.append(text[index])
                index = text.index(after: index)
            }
        }
        flushPending()
        return tokens
    }

    /// Registers the bundled `mana.ttf` with the process font manager. Idempotent.
    static func registerFont() {
        guard let url = Bundle.main.url(forResource: "mana", withExtension: "ttf") else {
            return
        }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        // Ignore "already registered" (and other) errors — registration is best-effort
        // and a second call on a warm process is expected to fail harmlessly.
        error?.release()
    }
}
