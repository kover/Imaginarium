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
    private var pendingLikeTask: URLSessionTask?
    
    private func photoURLRequest(pageNumber: Int) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/photos?page=\(pageNumber)", token: tokenStorage.token)
    }
    
    private func toggleLikeRequest(photoId: String, like: Bool) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/photos/\(photoId)/like", httpMethod: like ? "POST" : "DELETE", token: tokenStorage.token)
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
        
        let nextPage = lastLoadedPage == nil
        ? 1
        : lastLoadedPage! + 1
        
        guard Thread.isMainThread,
              task?.state != .running,
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
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: nil
                    )
                lastLoadedPage = nextPage
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard Thread.isMainThread,
              pendingLikeTask?.state != .running,
              let request = toggleLikeRequest(photoId: photoId, like: isLike) else {
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoLikeResult, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        targetImageURL: photo.targetImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
              
    }
}

