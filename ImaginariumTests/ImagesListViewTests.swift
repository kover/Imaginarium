//
//  ImagesListViewTests.swift
//  ImaginariumTests
//
//  Created by Konstantin Penzin on 13.08.2023.
//

@testable import Imaginarium
import XCTest

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: Imaginarium.ImagesListViewControllerProtocol?
    
    var photos: [Imaginarium.Photo] = []
    
    var photosCount: Int = 0
    
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func loadNextPage() {
        
    }
    
    func changeLike(at indexPath: IndexPath, for cell: Imaginarium.ImagesListCell) {
        
    }
    
    func imageHeight(at indexPath: IndexPath, for width: CGFloat) -> CGFloat {
        return 0
    }
    
    func configure(cell: Imaginarium.ImagesListCell, for indexPath: IndexPath) {
        
    }
}

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [Imaginarium.Photo] = []
    var changeLikeCalled = false
    var fetchPhotosNextPageCalled = false
    
    func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
    }
}

final class ImagesListViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        let _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsForLikeUpdate() {
        // given
        let presenter = ImagesListPresenter()
        let service = ImagesListServiceSpy()
        presenter.imagesListService = service
        presenter.photos = [
            Photo(
                id: "0",
                size: CGSize(width: 100, height: 100),
                createdAt: Date.now,
                welcomeDescription: "Test",
                thumbImageURL: "https://unsplash.com/thumbnail.jpg",
                targetImageURL: "https://unsplash.com/target.jpg",
                isLiked: false
            )
        ]
        
        // when
        presenter.changeLike(at: IndexPath(row: 0, section: 0), for: ImagesListCell())
        
        // then
        XCTAssertTrue(service.changeLikeCalled)
    }
    
    func testPresenterLoadsNextPageOnLoad() {
        // given
        let presenter = ImagesListPresenter()
        let service = ImagesListServiceSpy()
        presenter.imagesListService = service
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
}
