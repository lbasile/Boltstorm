//
//  Card.swift
//  Boltstorm
//

import Foundation

struct Card: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    private let manaCostValue: String?
    private let typeLineValue: String?
    private let oracleTextValue: String?
    private let flavorTextValue: String?
    private let imageUris: ImageUris?
    private let cardFaces: [CardFace]?

    var thumbnailURL: URL? {
        let urlString = imageUris?.small ?? cardFaces?.first?.imageUris?.small
        return urlString.flatMap(URL.init)
    }

    var artCropURL: URL? {
        let urlString = imageUris?.artCrop ?? cardFaces?.first?.imageUris?.artCrop
        return urlString.flatMap(URL.init)
    }

    // Detail fields fall back to the front face for double-faced cards,
    // mirroring the image fallback idiom above.
    var manaCost: String? { manaCostValue ?? cardFaces?.first?.manaCost }
    var typeLine: String? { typeLineValue ?? cardFaces?.first?.typeLine }
    var oracleText: String? { oracleTextValue ?? cardFaces?.first?.oracleText }
    var flavorText: String? { flavorTextValue ?? cardFaces?.first?.flavorText }

    private struct ImageUris: Decodable {
        let small: String?
        let artCrop: String?

        enum CodingKeys: String, CodingKey {
            case small
            case artCrop = "art_crop"
        }
    }

    private struct CardFace: Decodable {
        let imageUris: ImageUris?
        let manaCost: String?
        let typeLine: String?
        let oracleText: String?
        let flavorText: String?

        enum CodingKeys: String, CodingKey {
            case imageUris = "image_uris"
            case manaCost = "mana_cost"
            case typeLine = "type_line"
            case oracleText = "oracle_text"
            case flavorText = "flavor_text"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case manaCostValue = "mana_cost"
        case typeLineValue = "type_line"
        case oracleTextValue = "oracle_text"
        case flavorTextValue = "flavor_text"
        case imageUris = "image_uris"
        case cardFaces = "card_faces"
    }

    // Identity is the Scryfall id alone, so value-based navigation works without
    // making the private nested types Hashable.
    static func == (lhs: Card, rhs: Card) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct ScryfallSearchResponse: Decodable {
    let data: [Card]
}
