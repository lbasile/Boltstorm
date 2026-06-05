//
//  ScryfallService.swift
//  Boltstorm
//

import Foundation
import Observation

@Observable
final class ScryfallService {
    var results: [Card] = []
    var isLoading = false
    var errorMessage: String?

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func search(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        results = []

        var components = URLComponents(string: "https://api.scryfall.com/cards/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: trimmed)
        ]

        do {
            let (data, _) = try await session.data(from: components.url!)
            let response = try JSONDecoder().decode(ScryfallSearchResponse.self, from: data)
            results = response.data
        } catch {
            errorMessage = "No cards found for \"\(trimmed)\"."
        }

        isLoading = false
    }
}
