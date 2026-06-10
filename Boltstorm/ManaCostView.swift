//
//  ManaCostView.swift
//  Boltstorm
//
//  Renders a Scryfall mana-cost string (e.g. "{2}{R}{R}") as inline glyphs from
//  the bundled Mana font, with raw-text fallback for symbols that have no glyph.
//

import SwiftUI

struct ManaCostView: View {
    let manaCost: String
    var size: CGFloat = 17

    private var tokens: [ManaSymbology.Token] {
        ManaSymbology.tokens(in: manaCost)
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                switch token {
                case .text(let string):
                    Text(string)
                case .symbol(let tag):
                    if let glyph = ManaSymbology.glyph(for: tag) {
                        Text(String(glyph))
                            .font(.custom(ManaSymbology.fontName, size: size))
                    } else {
                        // No glyph for this tag (e.g. hybrid/Phyrexian) — show its text.
                        Text(tag)
                    }
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        let parts: [String] = tokens.compactMap { token in
            switch token {
            case .text(let string):
                let trimmed = string.trimmingCharacters(in: .whitespaces)
                return trimmed.isEmpty ? nil : trimmed
            case .symbol(let tag):
                return tag
            }
        }
        return parts.isEmpty ? "" : "Mana cost \(parts.joined(separator: " "))"
    }
}

#Preview {
    VStack(alignment: .trailing, spacing: 12) {
        ManaCostView(manaCost: "{R}")
        ManaCostView(manaCost: "{2}{R}{R}")
        ManaCostView(manaCost: "{X}{W}{U}{B}{R}{G}")
        ManaCostView(manaCost: "{1}{W/U}{T}") // hybrid falls back to text
    }
    .padding()
}
