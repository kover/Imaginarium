//
//  PhotoResult.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 25.07.2023.
//

import Foundation

// MARK: - PhotoResult
struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let width, height: Double
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
        case width, height, description, urls
    }
}
