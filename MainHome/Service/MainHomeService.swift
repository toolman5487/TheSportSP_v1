//
//  MainHomeService.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import Foundation

// MARK: - MainHomeServiceProtocol

protocol MainHomeServiceProtocol: Sendable {
    func fetchTodayCarouselEvents() async throws -> [MainCarouselModel]
}

// MARK: - MainHomeService

@MainActor
final class MainHomeService: MainHomeServiceProtocol {

    private let client = APIClient.shared

    func fetchTodayCarouselEvents() async throws -> [MainCarouselModel] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let dateString = formatter.string(from: Date())
        let path = SportsDBEndpoint.Schedule.eventsDay.pathWithKey()
        guard let url = client.url(path: path, queryItems: ["d": dateString]) else {
            throw APIError.invalidURL
        }
        let response: SportsDBEventsResponse = try await client.get(url: url)
        return (response.events ?? []).map { MainCarouselModel(sportsDBEvent: $0) }
    }
}
