//
//  UnsplashService.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.07.2023.
//

import Foundation

final class UnsplashService {
    static let shared = UnsplashService()
    
    private var urlSession = URLSession.shared
    
    private var selfProfileRequest: URLRequest {
        URLRequest.makeHTTPRequest(path: "/me")
    }
    
    func fetchSelfProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        let request = selfProfileRequest
        _ = object(Profile.self, for: request) { result in
            switch result {
            case .success(let body):
                completion(.success(body))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: - Shared helpers
extension UnsplashService {
    private func object<T: Codable>(
        _ type: T.Type,
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<T, Error> in
                Result {
                    try decoder.decode(T.self, from: data)
                }
            }
            completion(response)
        }
    }
}


// MARK: - Profile
struct Profile: Codable {
    let id: String
    let updatedAt: String
    let username, firstName, lastName: String
    let twitterUsername: String?
    let portfolioURL: String?
    let bio: String?
    let location: String?
    let totalLikes, totalPhotos, totalCollections: Int
    let followedByUser: Bool
    let downloads, uploadsRemaining: Int
    let instagramUsername: String?
    let email: String
    let links: Links

    enum CodingKeys: String, CodingKey {
        case id
        case updatedAt = "updated_at"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case twitterUsername = "twitter_username"
        case portfolioURL = "portfolio_url"
        case bio, location
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case followedByUser = "followed_by_user"
        case downloads
        case uploadsRemaining = "uploads_remaining"
        case instagramUsername = "instagram_username"
        case email, links
    }
}

// MARK: - Links
struct Links: Codable {
    let linksSelf, html, photos, likes: String
    let portfolio: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, photos, likes, portfolio
    }
}
