//
//  SportsDBEventModel.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import Foundation

// MARK: - SportsDBEventsResponse

struct SportsDBEventsResponse: Decodable {
    let events: [SportsDBEvent]?
}

// MARK: - SportsDBEvent

struct SportsDBEvent: Decodable, Sendable {
    let idEvent: String?
    let idAPIfootball: String?
    let strEvent: String?
    let strEventAlternate: String?
    let strFilename: String?
    let strSport: String?
    let idLeague: String?
    let strLeague: String?
    let strLeagueBadge: String?
    let strSeason: String?
    let strDescriptionEN: String?
    let strHomeTeam: String?
    let strAwayTeam: String?
    let intHomeScore: String?
    let intRound: String?
    let intAwayScore: String?
    let intSpectators: String?
    let strOfficial: String?
    let strTimestamp: String?
    let dateEvent: String?
    let dateEventLocal: String?
    let strTime: String?
    let strTimeLocal: String?
    let strGroup: String?
    let idHomeTeam: String?
    let strHomeTeamBadge: String?
    let idAwayTeam: String?
    let strAwayTeamBadge: String?
    let intScore: String?
    let intScoreVotes: String?
    let strResult: String?
    let idVenue: String?
    let strVenue: String?
    let strCountry: String?
    let strCity: String?
    let strPoster: String?
    let strSquare: String?
    let strFanart: String?
    let strThumb: String?
    let strBanner: String?
    let strMap: String?
    let strTweet1: String?
    let strVideo: String?
    let strStatus: String?
    let strPostponed: String?
    let strLocked: String?
}
