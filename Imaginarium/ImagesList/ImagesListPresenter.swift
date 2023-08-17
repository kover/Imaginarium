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
    func loadNextPage()
    func changeLike(at indexPath: IndexPath, for cell: ImagesListCell)
    func configure(cell: ImagesListCell, for indexPath: IndexPath)
    func updateTableViewAnimated()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private var helper: ImagesListHelperProtocol?
    
    private var imagesListService: ImagesListServiceProtocol?
    
    init(helper: ImagesListHelperProtocol?, imagesListService: ImagesListServiceProtocol?) {
        self.helper = helper
        self.imagesListService = imagesListService
    }
    
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
    
    func updateTableViewAnimated() {
        guard let imagesListService = imagesListService else {
            return
        }
        let currentCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if currentCount == newCount {
            return
        }
        
        view?.insertRows(from: currentCount, to: newCount)
    }
}

