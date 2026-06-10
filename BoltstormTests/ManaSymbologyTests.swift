//
//  ManaSymbologyTests.swift
//  BoltstormTests
//

import Testing
@testable import Boltstorm

struct ManaSymbologyTests {

    @Test func tokenizerSplitsSymbolsAndText() {
        let tokens = ManaSymbology.tokens(in: "{2}{R} deal damage")
        #expect(tokens == [
            .symbol("2"),
            .symbol("R"),
            .text(" deal damage"),
        ])
    }

    @Test func tokenizerHandlesEmptyString() {
        #expect(ManaSymbology.tokens(in: "").isEmpty)
    }

    @Test func tokenizerHandlesPlainTextWithNoSymbols() {
        #expect(ManaSymbology.tokens(in: "Counter target spell.") == [
            .text("Counter target spell."),
        ])
    }

    @Test func tokenizerTreatsUnclosedBraceAsText() {
        #expect(ManaSymbology.tokens(in: "{R") == [.text("{R")])
    }

    @Test func tokenizerHandlesLeadingAndTrailingText() {
        #expect(ManaSymbology.tokens(in: "Add {G} to your pool") == [
            .text("Add "),
            .symbol("G"),
            .text(" to your pool"),
        ])
    }

    @Test func glyphMapResolvesKnownTags() {
        #expect(ManaSymbology.glyph(for: "R") != nil)
        #expect(ManaSymbology.glyph(for: "T") != nil)
        #expect(ManaSymbology.glyph(for: "2") != nil)
        #expect(ManaSymbology.glyph(for: "20") != nil)
    }

    @Test func glyphMapIsCaseInsensitive() {
        #expect(ManaSymbology.glyph(for: "r") == ManaSymbology.glyph(for: "R"))
    }

    @Test func glyphMapReturnsNilForUnmappedTags() {
        #expect(ManaSymbology.glyph(for: "W/U") == nil)   // hybrid
        #expect(ManaSymbology.glyph(for: "W/P") == nil)   // Phyrexian
        #expect(ManaSymbology.glyph(for: "FOO") == nil)   // nonsense
    }
}
