//
//  Photo.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 25.07.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let targetImageURL: String
    let isLiked: Bool
}
