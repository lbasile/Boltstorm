//
//  Card.swift
//  Boltstorm
//

import Foundation

struct Card: Identifiable, Decodable {
    let id: String
    let name: String
    private let imageUris: ImageUris?
    private let cardFaces: [CardFace]?

    var thumbnailURL: URL? {
        let urlString = imageUris?.small ?? cardFaces?.first?.imageUris?.small
        return urlString.flatMap(URL.init)
    }

    private struct ImageUris: Decodable {
        let small: String
    }

    private struct CardFace: Decodable {
        let imageUris: ImageUris?

        enum CodingKeys: String, CodingKey {
            case imageUris = "image_uris"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageUris = "image_uris"
        case cardFaces = "card_faces"
    }
}

struct ScryfallSearchResponse: Decodable {
    let data: [Card]
}
