//
//  SearchEmptyView.swift
//  Boltstorm
//
//  Created by Louis Basile on 5/27/26.
//

import SwiftUI

struct SearchEmptyView: View {
    @State private var shouldAnimateMagnifier = true
    @State private var shouldAnimateContentUnavailableView = true

    var body: some View {
        ContentUnavailableView {
            Label {
                Text("Search for Cards")
            } icon: {
                Image(systemName: "text.magnifyingglass")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.black, .blue)
                    .symbolEffect(.drawOn, options: .speed(0.1), isActive: shouldAnimateMagnifier)
                    .task {
                        do {
                            try await Task.sleep(for: .seconds(1.8))
                            shouldAnimateMagnifier = false
                        } catch {
                        }
                    }
            }
        } description: {
            Text("Enter a card name to find matching cards.")
        }
        .opacity(shouldAnimateContentUnavailableView ? 0 : 1)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3).delay(0.8)) {
                shouldAnimateContentUnavailableView = false
            }
        }
    }
}

#Preview {
    SearchEmptyView()
}
