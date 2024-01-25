//
//  ProfileViewTest.swift
//  ImaginariumTests
//
//  Created by Konstantin Penzin on 12.08.2023.
//

@testable import Imaginarium
import XCTest

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: Imaginarium.ProfileViewControllerProtocol?
    
    var profileService: Imaginarium.ProfileServiceProtocol?
    
    var profileImageService: Imaginarium.ProfileImageServiceProtocol?
    
    var updatePofileDetailsCalled = false
    var updateProfileImageCalled = false
    
    func logoutAndCleanup() {
        
    }
    
    func updateProfileDetails() {
        updatePofileDetailsCalled = true
    }
    
    func updateProfileImage() {
        updateProfileImageCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: Imaginarium.ProfileViewPresenterProtocol?
    
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var numberOfCalls = 0
    
    func updateProfileDetails(profile: Imaginarium.Profile) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar(from avatarURL: String?) {
        updateAvatarCalled = true
        numberOfCalls += 1
    }
}

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: Imaginarium.Profile? = Profile(username: "username", name: "name", loginName: "loginName")
    
    func fetchProfile(completion: @escaping (Result<Imaginarium.ProfileResult, Error>) -> Void) {
        
    }
}

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String? = "http://unsplash.com/image.jpg"
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        NotificationCenter.default
            .post(name: ProfileImageService.didChangeNotification,
                  object: self,
                  userInfo: ["URL": "http://unsplash.com/image.jpg"]
            )
    }
    
}

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsUpdateFunctions() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        let _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.updatePofileDetailsCalled)
        XCTAssertTrue(presenter.updateProfileImageCalled)
    }
    
    func testPresenterUpdatesProfileDetails() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        let profileService = ProfileServiceStub()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.profileService = profileService
        
        // when
        presenter.updateProfileDetails()
        
        // then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
    }
    
    func testPresenterUpdatesProfileImageOnLoad() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        let profileImageService = ProfileImageServiceMock()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.profileImageService = profileImageService
        
        // when
        presenter.updateProfileImage()
        
        // then
        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.numberOfCalls, 1)
    }
    
    func testPresenterUpdatesProfileImageNotify() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        let profileImageService = ProfileImageServiceMock()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.profileImageService = profileImageService
        
        // when
        presenter.updateProfileImage()
        profileImageService.fetchProfileImageURL(username: "username") { _ in }
        
        // then
        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.numberOfCalls, 2)
    }
}
