//
//  UrlsResult.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 25.07.2023.
//

import Foundation

// MARK: - Urls
struct UrlsResult: Codable {
    let raw, full, regular, small: String
    let thumb: String
}
