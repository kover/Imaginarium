//
//  ProfileImageService.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 13.07.2023.
//

import Foundation

final class ProfileImageService: NetworkService {
    static let shared = ProfileImageService()
    
    var urlSession = URLSession.shared
    private var tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    
    private (set) var avatarURL: String?
    
    private func profileImageURLRequest(username: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/users/\(username)")
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = profileImageURLRequest(username: username) else {
            fatalError("Unable to create profile image request")
        }
        let task = object(UserResult.self, for: request) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                self.avatarURL = body.profileImage.small
                completion(.success(body.profileImage.small))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
    }
    
}

// MARK: - UserResult
struct UserResult: Codable {
    let id: String
    let updatedAt: String
    let username, name, firstName, lastName: String
    let instagramUsername, twitterUsername: String?
    let portfolioURL: String?
    let bio, location: String?
    let totalLikes, totalPhotos, totalCollections: Int
    let followedByUser: Bool
    let followersCount, followingCount, downloads: Int
    let social: Social
    let profileImage: ProfileImage
    let badge: Badge?
    let links: UserLinks

    enum CodingKeys: String, CodingKey {
        case id
        case updatedAt = "updated_at"
        case username, name
        case firstName = "first_name"
        case lastName = "last_name"
        case instagramUsername = "instagram_username"
        case twitterUsername = "twitter_username"
        case portfolioURL = "portfolio_url"
        case bio, location
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case followedByUser = "followed_by_user"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case downloads, social
        case profileImage = "profile_image"
        case badge, links
    }
}

// MARK: - Badge
struct Badge: Codable {
    let title: String
    let primary: Bool
    let slug: String
    let link: String
}

// MARK: - Links
struct UserLinks: Codable {
    let linksSelf, html, photos, likes: String
    let portfolio: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, photos, likes, portfolio
    }
}

// MARK: - ProfileImage
struct ProfileImage: Codable {
    let small, medium, large: String
}

// MARK: - Social
struct Social: Codable {
    let instagramUsername, portfolioURL, twitterUsername: String?

    enum CodingKeys: String, CodingKey {
        case instagramUsername = "instagram_username"
        case portfolioURL = "portfolio_url"
        case twitterUsername = "twitter_username"
    }
}
