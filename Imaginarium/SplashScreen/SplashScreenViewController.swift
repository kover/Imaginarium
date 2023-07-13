//
//  SplashScreenViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.07.2023.
//

import UIKit

final class SplashScreenViewController: UIViewController {
    private var showAuthenticationScreenSegue = "AuthenticationFlow"
    
    private let oauth2Service = OAuth2Service.shared
    private let oaut2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oaut2TokenStorage.token {
            UIBlockingProgressHUD.show()
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegue, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

// MARK: - Check authorization
extension SplashScreenViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegue {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegue)")
            }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashScreenViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.fetchAuthToken(code)
        }
    }
    
    private func fetchAuthToken(_ code: String) {
        oauth2Service.fetchAuthToken(withCode: code) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure:
                UIBlockingProgressHUD.dismiss()
                break
            }
        }
    }
}

// MARK: - Profile data
private extension SplashScreenViewController {
    private func fetchProfile(token: String) {
        profileService.fetchProfile { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let profile):
                profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case.failure:
                UIBlockingProgressHUD.dismiss()
                break
            }
        }
    }
}
