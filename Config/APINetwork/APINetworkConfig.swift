//
//  APINetworkConfig.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import Foundation

// MARK: - APINetworkConfig

enum APINetworkConfig: Sendable {
    static var baseURL: String = ""
}

// MARK: - HTTPMethod

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - APIError

enum APIError: Error, Sendable {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int, data: Data?)
    case networkError(Error)
}

// MARK: - APIClient

struct APIClient: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    static let shared = APIClient()

    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpBody = body

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverError(statusCode: http.statusCode, data: data)
        }

        return data
    }

    func request<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        let data = try await request(url: url, method: method, headers: headers, body: body)
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func get(url: URL, queryItems: [String: String]? = nil, headers: [String: String]? = nil) async throws -> Data {
        let urlWithQuery = urlWithQueryItems(url: url, queryItems: queryItems)
        return try await request(url: urlWithQuery, method: .get, headers: headers, body: nil)
    }

    func get<T: Decodable>(
        url: URL,
        queryItems: [String: String]? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        let urlWithQuery = urlWithQueryItems(url: url, queryItems: queryItems)
        return try await request(url: urlWithQuery, method: .get, headers: headers, body: nil)
    }

    func post(url: URL, body: Data? = nil, headers: [String: String]? = nil) async throws -> Data {
        try await request(url: url, method: .post, headers: headers, body: body)
    }

    func post<T: Decodable>(
        url: URL,
        body: some Encodable,
        headers: [String: String]? = nil
    ) async throws -> T {
        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        return try await request(url: url, method: .post, headers: headers, body: data)
    }

    func put(url: URL, body: Data? = nil, headers: [String: String]? = nil) async throws -> Data {
        try await request(url: url, method: .put, headers: headers, body: body)
    }

    func put<T: Decodable>(
        url: URL,
        body: some Encodable,
        headers: [String: String]? = nil
    ) async throws -> T {
        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        return try await request(url: url, method: .put, headers: headers, body: data)
    }

    func patch(url: URL, body: Data? = nil, headers: [String: String]? = nil) async throws -> Data {
        try await request(url: url, method: .patch, headers: headers, body: body)
    }

    func patch<T: Decodable>(
        url: URL,
        body: some Encodable,
        headers: [String: String]? = nil
    ) async throws -> T {
        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        return try await request(url: url, method: .patch, headers: headers, body: data)
    }

    func delete(url: URL, headers: [String: String]? = nil) async throws -> Data {
        try await request(url: url, method: .delete, headers: headers, body: nil)
    }

    func delete<T: Decodable>(url: URL, headers: [String: String]? = nil) async throws -> T {
        try await request(url: url, method: .delete, headers: headers, body: nil)
    }

    private func urlWithQueryItems(url: URL, queryItems: [String: String]?) -> URL {
        guard let queryItems, !queryItems.isEmpty else { return url }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url ?? url
    }
}

// MARK: - URL + Path

extension APIClient {
    func url(path: String, queryItems: [String: String]? = nil) -> URL? {
        let base = APINetworkConfig.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let pathTrimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let full = base.isEmpty ? pathTrimmed : "\(base)/\(pathTrimmed)"
        guard var components = URLComponents(string: full) else { return nil }
        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return components.url
    }
}
