//
//  APIConfig .swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import Foundation

enum APIConfig {
    static let freeAPIKey = "123"
}

// MARK: - SportsDB Endpoint Path

protocol SportsDBEndpointPath: RawRepresentable, Sendable where RawValue == String {
    var path: String { get }
    func pathWithKey(_ key: String) -> String
}

extension SportsDBEndpointPath {
    var path: String { rawValue }
    func pathWithKey(_ key: String = APIConfig.freeAPIKey) -> String {
        "\(key)/\(rawValue)"
    }
}

// MARK: - SportsDB Endpoint

enum SportsDBEndpoint {
    enum Search: String, CaseIterable, SportsDBEndpointPath {
        case teams = "searchteams.php"
        case events = "searchevents.php"
        case players = "searchplayers.php"
        case venues = "searchvenues.php"
    }

    enum Lookup: String, CaseIterable, SportsDBEndpointPath {
        case league = "lookupleague.php"
        case table = "lookuptable.php"
        case team = "lookupteam.php"
        case equipment = "lookupequipment.php"
        case player = "lookupplayer.php"
        case honours = "lookuphonours.php"
        case formerTeams = "lookupformerteams.php"
        case milestones = "lookupmilestones.php"
        case contracts = "lookupcontracts.php"
        case playerResults = "playerresults.php"
        case event = "lookupevent.php"
        case eventResults = "eventresults.php"
        case lineup = "lookuplineup.php"
        case timeline = "lookuptimeline.php"
        case eventStats = "lookupeventstats.php"
        case tv = "lookuptv.php"
        case venue = "lookupvenue.php"
    }

    enum List: String, CaseIterable, SportsDBEndpointPath {
        case allSports = "all_sports.php"
        case allCountries = "all_countries.php"
        case allLeagues = "all_leagues.php"
        case searchAllLeagues = "search_all_leagues.php"
        case searchAllSeasons = "search_all_seasons.php"
        case searchAllTeams = "search_all_teams.php"
        case lookupAllPlayers = "lookup_all_players.php"
    }

    enum Schedule: String, CaseIterable, SportsDBEndpointPath {
        case eventsNext = "eventsnext.php"
        case eventsLast = "eventslast.php"
        case eventsNextLeague = "eventsnextleague.php"
        case eventsPastLeague = "eventspastleague.php"
        case eventsDay = "eventsday.php"
        case eventsSeason = "eventsseason.php"
        case eventsTV = "eventstv.php"
    }

    enum Video: String, CaseIterable, SportsDBEndpointPath {
        case highlights = "eventshighlights.php"
    }
}
