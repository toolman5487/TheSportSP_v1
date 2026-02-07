//
//  MainCarouselModel.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import Foundation

// MARK: - MainCarouselModel

struct MainCarouselModel: Sendable {
    let id: String?
    let imageURL: String?
    let title: String?
    let subtitle: String?

    init(id: String? = nil, imageURL: String? = nil, title: String? = nil, subtitle: String? = nil) {
        self.id = id
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
    }

    init(sportsDBEvent: SportsDBEvent) {
        id = sportsDBEvent.idEvent
        imageURL = sportsDBEvent.strThumb ?? sportsDBEvent.strBanner ?? sportsDBEvent.strPoster
        title = sportsDBEvent.strEvent
        let parts = [sportsDBEvent.strLeague, sportsDBEvent.dateEvent].compactMap { $0 }.filter { !$0.isEmpty }
        subtitle = parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
