//
//  CardDetailView.swift
//  Boltstorm
//
//  Scrollable detail screen: art, name + mana cost, type line, oracle text, and
//  (conditional) flavor text — top to bottom, like the Scryfall web detail view.
//

import SwiftUI

struct CardDetailView: View {
    let card: Card

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CardArtView(url: card.artCropURL)

                HStack(alignment: .firstTextBaseline) {
                    Text(card.name)
                        .font(.title2.weight(.semibold))
                    Spacer(minLength: 12)
                    if let manaCost = card.manaCost, !manaCost.isEmpty {
                        ManaCostView(manaCost: manaCost, size: 20)
                    }
                }

                Divider()

                if let typeLine = card.typeLine, !typeLine.isEmpty {
                    Text(typeLine)
                        .font(.headline)
                    Divider()
                }

                if let oracleText = card.oracleText, !oracleText.isEmpty {
                    Text(oracleText)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let flavorText = card.flavorText, !flavorText.isEmpty {
                    Text(flavorText)
                        .font(.body)
                        .italic()
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Maps `AsyncImage` phases to a named loading status and renders the art crop,
/// capped at roughly a quarter of the screen height. Failure shows a gray block
/// with an SF Symbol, reusing the placeholder idiom from `CardRow`.
private struct CardArtView: View {
    let url: URL?

    enum ImageLoadingStatus { case loading, success, failed }

    private var maxHeight: CGFloat {
        UIScreen.main.bounds.height * 0.25
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch status(for: phase) {
            case .success:
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            case .loading:
                placeholder { ProgressView() }
            case .failed:
                placeholder {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: maxHeight)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func status(for phase: AsyncImagePhase) -> ImageLoadingStatus {
        switch phase {
        case .empty: return url == nil ? .failed : .loading
        case .success: return .success
        case .failure: return .failed
        @unknown default: return .failed
        }
    }

    private func placeholder<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.secondary.opacity(0.2))
            .overlay(content())
    }
}

#Preview("With flavor") {
    NavigationStack {
        CardDetailView(card: .previewLightningBolt)
    }
}

#Preview("No flavor") {
    NavigationStack {
        CardDetailView(card: .previewNoFlavor)
    }
}

extension Card {
    /// Decodes a `Card` from a JSON literal — `Card` exposes only its `Decodable`
    /// initializer, so previews/tests build instances this way.
    fileprivate static func decoded(from json: String) -> Card {
        try! JSONDecoder().decode(Card.self, from: Data(json.utf8))
    }

    fileprivate static let previewLightningBolt = decoded(from: """
    {
      "id": "bolt",
      "name": "Lightning Bolt",
      "mana_cost": "{R}",
      "type_line": "Instant",
      "oracle_text": "Lightning Bolt deals 3 damage to any target.",
      "flavor_text": "The sparkmage shrieked, calling on the rage of the storms."
    }
    """)

    fileprivate static let previewNoFlavor = decoded(from: """
    {
      "id": "counter",
      "name": "Counterspell",
      "mana_cost": "{U}{U}",
      "type_line": "Instant",
      "oracle_text": "Counter target spell."
    }
    """)
}
