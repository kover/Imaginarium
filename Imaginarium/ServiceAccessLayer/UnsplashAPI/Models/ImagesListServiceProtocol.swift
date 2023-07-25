//
//  ImageListServiceProtocol.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 25.07.2023.
//

import Foundation

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
}
