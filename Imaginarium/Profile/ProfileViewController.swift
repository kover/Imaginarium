//
//  ProfileViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 08.06.2023.
//

import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    // MARK: - Outlets
    private var profilePictureImageView: UIImageView!
    private var fullNameLabel: UILabel!
    private var userNameLabel: UILabel!
    private var profileDescriptionLabel: UILabel!
    private var logoutButton: UIButton!
    
    var profileService: ProfileServiceProtocol?
    var profileImageService: ProfileImageServiceProtocol?
    
    // MARK: - Notifications
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle and ViewController overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var tokenStorage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        addProfileImageView()
        addFullNameLabel()
        addUserNameLabel()
        addDescriptionLabel()
        addLogoutButton()
        
        if let profile = profileService?.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    // MARK: - Actions
    @objc private func logoutTap() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.logoutAndCleanup()
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func logoutAndCleanup() {
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
    
    // MARK: - Manual layout
    private func addProfileImageView() {
        let image = UIImage(named: "Userpic")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        profilePictureImageView = imageView
        imageView.tintColor = UIColor(named: "YP Gray")
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }
    
    private func addFullNameLabel() {
        let label = UILabel()
        fullNameLabel = label
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.text = "User Name"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: profilePictureImageView.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }
    
    private func addUserNameLabel() {
        let label = UILabel()
        userNameLabel = label
        label.textColor = UIColor(named: "YP Gray")
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "@userName"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: profilePictureImageView.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }
    
    private func addDescriptionLabel() {
        let label = UILabel()
        profileDescriptionLabel = label
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Hello world"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: profilePictureImageView.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }
    
    private func addLogoutButton() {
        guard let logoutIcon = UIImage(systemName: "ipad.and.arrow.forward") else {
            return
        }
        
        let button = UIButton.systemButton(
            with: logoutIcon,
            target: self,
            action: #selector(Self.logoutTap)
        )
        logoutButton = button
        button.tintColor = UIColor(named: "YP Red")
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: profilePictureImageView.centerYAnchor)
        ])
    }
}

// MARK: - Profile Data
private extension ProfileViewController {
    private func updateProfileDetails(profile: Profile) {
        fullNameLabel.text = profile.name
        userNameLabel.text = profile.loginName
        profileDescriptionLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService?.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            return
        }
        
        let processor = RoundCornerImageProcessor(radius: .widthFraction(0.5), backgroundColor: UIColor(named: "YP Black"))
        profilePictureImageView.kf.indicatorType = .activity
        profilePictureImageView.kf.setImage(with: url, placeholder: UIImage(named: "Profile Stub"), options: [.processor(processor)])
    }
}
