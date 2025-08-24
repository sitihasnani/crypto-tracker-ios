//
//  APIClient.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(URLError)
    case decodingError(Error)
    case badStatusCode(Int)
    case tooManyRequests
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error): return error.localizedDescription
        case .decodingError: return "Decoding Error"
        case .badStatusCode(let code): return "Bad Status Code: \(code)"
        case .tooManyRequests: return "Too Many Requests. Please slow down"
        case .unknown: return "Unknown Error"
        }
    }
}

final class APIClient {
    private let base = URL(string: "https://api.coingecko.com/api/v3")!
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        guard var comps = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
        throw APIError.invalidURL
        }
        comps.queryItems = query.isEmpty ? nil : query
        guard let url = comps.url else { throw APIError.invalidURL }

        let (data, resp): (Data, URLResponse)
        do {
        (data, resp) = try await session.data(from: url)
        } catch let e as URLError { throw APIError.networkError(e) }
        catch { throw APIError.unknown }

        guard let http = resp as? HTTPURLResponse else { throw APIError.unknown }
        switch http.statusCode {
        case 200..<300:
            break
        case 429:
            throw APIError.tooManyRequests
        default:
            throw APIError.badStatusCode(http.statusCode)
        }

        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { throw APIError.decodingError(error) }
    }


}
