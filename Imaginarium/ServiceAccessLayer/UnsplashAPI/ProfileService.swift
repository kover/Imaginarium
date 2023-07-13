//
//  UnsplashService.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.07.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private var urlSession = URLSession.shared
    private var tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    
    private var selfProfileRequest: URLRequest? {
        URLRequest.makeHTTPRequest(path: "/me", token: tokenStorage.token)
    }
    
    private (set) var profile: Profile?
    
    func fetchProfile(completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = selfProfileRequest else {
            fatalError("Unable to create fetchSelfProfile request")
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                self.setUserProfile(result: body)
                completion(.success(body))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
    }
    
}

// MARK: - Shared helpers
extension ProfileService {
    private func setUserProfile(result: ProfileResult) {
        let profile = Profile(
            username: result.username,
            name: "\(result.firstName) \(result.lastName)",
            loginName: "@\(result.username)",
            bio: result.bio
        )
        self.profile = profile
    }
}


// MARK: - ProfileResult
struct ProfileResult: Codable {
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

// MARK: - Profile
struct Profile {
    var username: String
    var name: String
    var loginName: String
    var bio: String?
}
