//
//  MainHomeService.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import Foundation

// MARK: - MainHomeService

@MainActor
final class MainHomeService {

    private let client = APIClient.shared

    func fetchCarouselEvents(teamId: String) async throws -> [MainCarouselModel] {
        let path = SportsDBEndpoint.Schedule.eventsNext.pathWithKey()
        guard let url = client.url(path: path, queryItems: ["id": teamId]) else {
            throw APIError.invalidURL
        }
        let response: SportsDBEventsResponse = try await client.get(url: url)
        return (response.events ?? []).map { MainCarouselModel(sportsDBEvent: $0) }
    }

    func fetchCarouselEvents(leagueId: String) async throws -> [MainCarouselModel] {
        let path = SportsDBEndpoint.Schedule.eventsNextLeague.pathWithKey()
        guard let url = client.url(path: path, queryItems: ["id": leagueId]) else {
            throw APIError.invalidURL
        }
        let response: SportsDBEventsResponse = try await client.get(url: url)
        return (response.events ?? []).map { MainCarouselModel(sportsDBEvent: $0) }
    }
}
