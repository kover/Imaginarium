//
//  ImageListService.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 25.07.2023.
//

import Foundation

final class ImagesListService: ImagesListServiceProtocol {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    private let urlSession = URLSession.shared
    private var tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    
    private func photoURLRequest(pageNumber: Int) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/photos?page=\(pageNumber)", token: tokenStorage.token)
    }
    
    func fetchPhotosNextPage() {
        
        let nextPage = lastLoadedPage == nil
        ? 1
        : lastLoadedPage! + 1
        
        guard Thread.isMainThread,
              task == nil,
              let request = photoURLRequest(pageNumber: nextPage) else {
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let photoResult):
                photos.append(contentsOf: photoResult.map({ item in
                    Photo(
                        id: item.id,
                        size: CGSize(width: item.width, height: item.height),
                        createdAt: item.createdAt,
                        welcomeDescription: item.description,
                        thumbImageURL: item.urls.thumb,
                        targetImageURL: item.urls.full,
                        isLiked: item.likedByUser
                    )
                }))
                NotificationCenter.default
                    .post(name: ImagesListService.didChangeNotification,
                    object: self,
                          userInfo: nil)
            case .failure:
                // TODO: Handle error
                return
            }
        }
        
        self.task = task
    }
}
