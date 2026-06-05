//
//  ScryfallServiceTests.swift
//  BoltstormTests
//

import Testing
import Foundation
@testable import Boltstorm

// MARK: - Mock

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Helpers

private func makeMockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

private func makeOKResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: URL(string: "https://api.scryfall.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
}

private let singleCardJSON = Data("""
{
  "data": [
    {
      "id": "abc123",
      "name": "Lightning Bolt",
      "image_uris": { "small": "https://cards.scryfall.io/small/front/e/3/e3285e6b-3e79-4d7c-bf96-d920f973b122.jpg" }
    }
  ]
}
""".utf8)

private let multiCardJSON = Data("""
{
  "data": [
    { "id": "1", "name": "Island" },
    { "id": "2", "name": "Forest" },
    { "id": "3", "name": "Mountain" }
  ]
}
""".utf8)

private let doubleFacedCardJSON = Data("""
{
  "data": [
    {
      "id": "df1",
      "name": "Delver of Secrets // Insectile Aberration",
      "card_faces": [
        { "image_uris": { "small": "https://cards.scryfall.io/small/front/df1.jpg" } },
        { "image_uris": { "small": "https://cards.scryfall.io/small/back/df1.jpg" } }
      ]
    }
  ]
}
""".utf8)

// MARK: - Tests

// Serialized because MockURLProtocol.requestHandler is shared mutable static state.
@Suite(.serialized)
struct ScryfallServiceTests {

    @Test func successfulSearchPopulatesResults() async {
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), singleCardJSON) }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "Lightning Bolt")

        #expect(service.results.count == 1)
        await #expect(service.results.first?.name == "Lightning Bolt")
        #expect(service.errorMessage == nil)
        #expect(service.isLoading == false)
    }

    @Test func multipleResultsAreAllReturned() async {
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), multiCardJSON) }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "basic land")

        #expect(service.results.count == 3)
    }

    @Test func doubleFacedCardThumbnailUsesFirstFace() async {
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), doubleFacedCardJSON) }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "Delver of Secrets")

        let card = await service.results.first
        #expect(card?.thumbnailURL?.absoluteString == "https://cards.scryfall.io/small/front/df1.jpg")
    }

    @Test func emptyQueryDoesNotTouchNetwork() async {
        var handlerWasCalled = false
        MockURLProtocol.requestHandler = { _ in handlerWasCalled = true; throw URLError(.unknown) }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "")

        #expect(!handlerWasCalled)
        #expect(service.results.isEmpty)
        #expect(service.errorMessage == nil)
    }

    @Test func whitespaceOnlyQueryDoesNotTouchNetwork() async {
        var handlerWasCalled = false
        MockURLProtocol.requestHandler = { _ in handlerWasCalled = true; throw URLError(.unknown) }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "   ")

        #expect(!handlerWasCalled)
        #expect(service.results.isEmpty)
    }

    @Test func queryIsTrimmedBeforeSendingToAPI() async throws {
        var capturedURL: URL?
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            return (makeOKResponse(), singleCardJSON)
        }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "  Lightning Bolt  ")

        let components = try #require(capturedURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })
        let q = components.queryItems?.first(where: { $0.name == "q" })?.value
        #expect(q == "Lightning Bolt")
    }

    @Test func networkErrorSetsErrorMessage() async {
        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "Counterspell")

        #expect(service.results.isEmpty)
        #expect(service.errorMessage == "No cards found for \"Counterspell\".")
        #expect(service.isLoading == false)
    }

    @Test func invalidJSONSetsErrorMessage() async {
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), Data("not json".utf8)) }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "Island")

        #expect(service.results.isEmpty)
        #expect(service.errorMessage == "No cards found for \"Island\".")
    }

    @Test func isLoadingIsFalseAfterSuccess() async {
        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), singleCardJSON) }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "Forest")

        #expect(service.isLoading == false)
    }

    @Test func isLoadingIsFalseAfterError() async {
        MockURLProtocol.requestHandler = { _ in throw URLError(.timedOut) }
        let service = await ScryfallService(session: makeMockSession())

        await service.search(query: "Mountain")

        #expect(service.isLoading == false)
    }

    @Test func successfulSearchClearsPreviousError() async {
        MockURLProtocol.requestHandler = { _ in throw URLError(.timedOut) }
        let service = await ScryfallService(session: makeMockSession())
        await service.search(query: "Mountain")
        #expect(service.errorMessage != nil)

        MockURLProtocol.requestHandler = { _ in (makeOKResponse(), singleCardJSON) }
        await service.search(query: "Lightning Bolt")

        #expect(service.errorMessage == nil)
        #expect(service.results.count == 1)
    }
}
