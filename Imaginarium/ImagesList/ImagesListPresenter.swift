//
//  ImagesListPresenter.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 13.08.2023.
//

import UIKit

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    var photosCount: Int { get }
    func viewDidLoad()
    func loadNextPage()
    func changeLike(at indexPath: IndexPath, for cell: ImagesListCell)
    func imageHeight(at indexPath: IndexPath, for width: CGFloat) -> CGFloat
    func configure(cell: ImagesListCell, for indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    var helper: ImagesListHelperProtocol?
    
    var imagesListService: ImagesListServiceProtocol?
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    var photos: [Photo] = []
    
    var photosCount: Int {
        get {
            return imagesListService?.photos.count ?? 0
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.updateTableViewAnimated()
            }
        
        loadNextPage()
    }
    
    func loadNextPage() {
        imagesListService?.fetchPhotosNextPage(completion: { [weak self] result in
            switch result {
            case .failure:
                self?.showPageLoadError()
            default:
                return
            }
        })
    }
    
    func changeLike(at indexPath: IndexPath, for cell: ImagesListCell) {
        let photo  = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService?.changeLike(photoId: photo.id, isLike: !photo.isLiked, { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                if let servicePhotos = self.imagesListService?.photos {
                    self.photos = servicePhotos
                }
                cell.setIsLiked(isLiked: !photo.isLiked)
            case .failure:
                self.showChangeLikeError()
            }
            UIBlockingProgressHUD.dismiss()
        })
    }
    
    func imageHeight(at indexPath: IndexPath, for width: CGFloat) -> CGFloat {
        let imageSize = photos[indexPath.row].size
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func configure(cell: ImagesListCell, for indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        var postedAt = ""
        if let createdAt = photo.createdAt {
            postedAt = dateFormatter.string(from: createdAt)
        }
        cell.configureCell(forPhoto: photo.thumbImageURL, postedAt: postedAt, liked: photo.isLiked) {}
    }
    
    private func showPageLoadError() {
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel) { [weak self] _ in
            self?.view?.dismisAlert()
        }
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadNextPage()
        }
        guard let alert = helper?.showError(message: "Что-то пошло не так. Попробовать ещё раз?", retryAction: retryAction, cancelAction: cancelAction) else {
            return
        }
        
        view?.presentAlert(alert)
    }
    
    private func showChangeLikeError() {
        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel) { [weak self] _ in
            self?.view?.dismisAlert()
        }
        
        guard let alert = helper?.showError(message: "Что-то пошло не так. Попробуйте позже", retryAction: nil, cancelAction: cancelAction) else {
            return
        }
        
        view?.presentAlert(alert)
    }
    
    private func updateTableViewAnimated() {
        guard let imagesListService = imagesListService else {
            return
        }
        let currentCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if currentCount == newCount {
            return
        }
        
        view?.feedTableView.performBatchUpdates {
            view?.feedTableView.insertRows(at: (currentCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }, with: .automatic)
        }

    }
}

