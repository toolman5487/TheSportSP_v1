//
//  SportsDBListModels.swift
//  TheSportSP
//
//  共用 SportsDB List 類別的回傳 Model（all_sports / all_leagues / all_teams 等）。
//

import Foundation

// MARK: - SportsDB List: All Sports

struct SportsDBAllSportsResponse: Decodable {
    let sports: [SportsDBSport]?
}

struct SportsDBSport: Decodable, Sendable {
    let idSport: String?
    let strSport: String?
    let strFormat: String?
    let strSportThumb: String?
    let strSportIconGreen: String?
    let strSportDescription: String?
}

// MARK: - SportsDB List: All Countries

struct SportsDBAllCountriesResponse: Decodable {
    let countries: [SportsDBCountry]?
}

struct SportsDBCountry: Decodable, Sendable {
    let name_en: String?
    let name_int: String?
}

// MARK: - SportsDB List: Leagues

struct SportsDBAllLeaguesResponse: Decodable {
    let leagues: [SportsDBLeague]?
}

struct SportsDBLeague: Decodable, Sendable {
    let idLeague: String?
    let strLeague: String?
    let strSport: String?
    let strLeagueAlternate: String?
    let strLeagueShort: String?
    let strDivision: String?
    let strCountry: String?
    let strBadge: String?
    let strLogo: String?
    let strFanart1: String?
    let strPoster: String?
    let strDescriptionEN: String?
}

// MARK: - SportsDB List: Seasons

struct SportsDBAllSeasonsResponse: Decodable {
    let seasons: [SportsDBSeason]?
}

struct SportsDBSeason: Decodable, Sendable {
    let strSeason: String?
}

// MARK: - SportsDB List: Teams

struct SportsDBAllTeamsResponse: Decodable {
    let teams: [SportsDBTeam]?
}

struct SportsDBTeam: Decodable, Sendable {
    let idTeam: String?
    let strTeam: String?
    let strTeamShort: String?
    let strAlternate: String?
    let idLeague: String?
    let strLeague: String?
    let strSport: String?
    let strCountry: String?
    let strStadium: String?
    let strStadiumThumb: String?
    let strTeamBadge: String?
    let strTeamLogo: String?
    let strTeamJersey: String?
    let strDescriptionEN: String?
}

// MARK: - SportsDB List: Players

struct SportsDBAllPlayersResponse: Decodable {
    let player: [SportsDBPlayer]?
}

struct SportsDBPlayer: Decodable, Sendable {
    let idPlayer: String?
    let idTeam: String?
    let idTeam2: String?
    let idLeague: String?
    let strSport: String?
    let strPlayer: String?
    let strNationality: String?
    let dateBorn: String?
    let strPosition: String?
    let strHeight: String?
    let strWeight: String?
    let strThumb: String?
    let strCutout: String?
    let strRender: String?
    let strFanart1: String?
    let strDescriptionEN: String?
}

