//
//  ProfilePresenter.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 12.08.2023.
//

import UIKit
import WebKit

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var profileService: ProfileServiceProtocol? { get set }
    var profileImageService: ProfileImageServiceProtocol? { get set }
    func logoutAndCleanup()
    func updateProfileDetails()
    func updateProfileImage()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var profileService: ProfileServiceProtocol?
    var profileImageService: ProfileImageServiceProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var tokenStorage = OAuth2TokenStorage()
    
    weak var view: ProfileViewControllerProtocol?
    
    func logoutAndCleanup() {
        guard tokenStorage.removeToken(), let window = (UIApplication.shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .last { $0.isKeyWindow }) else {
                return
            }
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
            window.rootViewController = SplashScreenViewController()
        }
    }
    
    func updateProfileDetails() {
        if let profile = profileService?.profile {
            view?.updateProfileDetails(profile: profile)
        }
    }
    
    func updateProfileImage() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.view?.updateAvatar(from: profileImageService?.avatarURL)
            }
        view?.updateAvatar(from: profileImageService?.avatarURL)
    }
}
