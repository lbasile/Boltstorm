//
//  ContentView.swift
//  Boltstorm
//
//  Created by Louis Basile on 5/27/26.
//

import SwiftUI

struct ContentView: View {
    @State private var service = ScryfallService()
    @State private var query = ""
    var body: some View {
        NavigationStack {
            List(service.results) { card in
                NavigationLink(value: card) {
                    CardRow(card: card)
                }
            }
            .navigationDestination(for: Card.self) { card in
                CardDetailView(card: card)
            }
            .overlay {
                if service.isLoading {
                    ProgressView()
                } else if let error = service.errorMessage {
                    ContentUnavailableView(error, systemImage: "magnifyingglass")
                } else if service.results.isEmpty {
                    SearchEmptyView()
                }
            }
            .navigationTitle("Boltstorm")
            .searchable(text: $query, prompt: "Card name...")
            .onSubmit(of: .search) {
                Task { await service.search(query: query) }
            }
        }
    }
}

struct CardRow: View {
    let card: Card

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: card.thumbnailURL) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fit)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                }
            }
            .frame(width: 44, height: 62)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            Text(card.name)
                .font(.body)

            Spacer()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ContentView()
}
