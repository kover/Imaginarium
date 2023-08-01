//
//  PhotoLikeResult.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 26.07.2023.
//

import Foundation

struct PhotoLikeResult: Codable {
    let photo: PhotoResult
    
    enum CodingKeys: String, CodingKey {
        case photo
    }
}
