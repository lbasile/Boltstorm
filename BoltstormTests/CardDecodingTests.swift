//
//  CardDecodingTests.swift
//  BoltstormTests
//

import Testing
import Foundation
@testable import Boltstorm

private func decode(_ json: String) throws -> Card {
    try JSONDecoder().decode(Card.self, from: Data(json.utf8))
}

struct CardDecodingTests {

    @Test func fullCardDecodesAllDetailFields() throws {
        let card = try decode("""
        {
          "id": "bolt",
          "name": "Lightning Bolt",
          "mana_cost": "{R}",
          "type_line": "Instant",
          "oracle_text": "Lightning Bolt deals 3 damage to any target.",
          "flavor_text": "The sparkmage shrieked.",
          "image_uris": {
            "small": "https://cards.scryfall.io/small/bolt.jpg",
            "art_crop": "https://cards.scryfall.io/art_crop/bolt.jpg"
          }
        }
        """)

        #expect(card.manaCost == "{R}")
        #expect(card.typeLine == "Instant")
        #expect(card.oracleText == "Lightning Bolt deals 3 damage to any target.")
        #expect(card.flavorText == "The sparkmage shrieked.")
        #expect(card.artCropURL?.absoluteString == "https://cards.scryfall.io/art_crop/bolt.jpg")
        #expect(card.thumbnailURL?.absoluteString == "https://cards.scryfall.io/small/bolt.jpg")
    }

    @Test func missingFlavorTextIsNil() throws {
        let card = try decode("""
        {
          "id": "counter",
          "name": "Counterspell",
          "mana_cost": "{U}{U}",
          "type_line": "Instant",
          "oracle_text": "Counter target spell."
        }
        """)

        #expect(card.flavorText == nil)
        #expect(card.oracleText == "Counter target spell.")
    }

    @Test func doubleFacedCardFallsBackToFirstFace() throws {
        let card = try decode("""
        {
          "id": "delver",
          "name": "Delver of Secrets // Insectile Aberration",
          "card_faces": [
            {
              "mana_cost": "{U}",
              "type_line": "Creature — Human Wizard",
              "oracle_text": "At the beginning of your upkeep, look at the top card.",
              "flavor_text": "Who knows what lurks beneath?",
              "image_uris": {
                "small": "https://cards.scryfall.io/small/front/delver.jpg",
                "art_crop": "https://cards.scryfall.io/art_crop/front/delver.jpg"
              }
            },
            {
              "mana_cost": "",
              "type_line": "Creature — Human Insect",
              "oracle_text": "Flying",
              "image_uris": {
                "small": "https://cards.scryfall.io/small/back/delver.jpg"
              }
            }
          ]
        }
        """)

        #expect(card.manaCost == "{U}")
        #expect(card.typeLine == "Creature — Human Wizard")
        #expect(card.oracleText == "At the beginning of your upkeep, look at the top card.")
        #expect(card.flavorText == "Who knows what lurks beneath?")
        #expect(card.artCropURL?.absoluteString == "https://cards.scryfall.io/art_crop/front/delver.jpg")
    }

    @Test func minimalSearchJSONStillDecodes() throws {
        let card = try decode("""
        {
          "id": "abc123",
          "name": "Lightning Bolt",
          "image_uris": { "small": "https://cards.scryfall.io/small/bolt.jpg" }
        }
        """)

        #expect(card.name == "Lightning Bolt")
        #expect(card.manaCost == nil)
        #expect(card.typeLine == nil)
        #expect(card.flavorText == nil)
        #expect(card.artCropURL == nil)
        #expect(card.thumbnailURL?.absoluteString == "https://cards.scryfall.io/small/bolt.jpg")
    }

    @Test func cardsAreEqualByIdAlone() throws {
        let a = try decode(#"{ "id": "x", "name": "Front" }"#)
        let b = try decode(#"{ "id": "x", "name": "Different Name" }"#)
        let c = try decode(#"{ "id": "y", "name": "Front" }"#)

        #expect(a == b)
        #expect(a != c)
        #expect(a.hashValue == b.hashValue)
    }
}
