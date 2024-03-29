//
//  SplashScreenViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.07.2023.
//

import UIKit

final class SplashScreenViewController: UIViewController {
    
    private var logoImageView: UIImageView!
    
    private let oauth2Service = OAuth2Service.shared
    private let oaut2TokenStorage = OAuth2TokenStorage()
    private let profileService: ProfileServiceProtocol = ProfileService()
    private let profileImageService: ProfileImageServiceProtocol = ProfileImageService()
    
    private var alertPresenter: AlertPresenterProtocol!
    
    // This one is used to prevent fetching token/profile when modals are dismissed
    private var isAlreadyShown = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        alertPresenter = AlertPresenter(delegate: self)
        addLogoImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAlreadyShown {
            return
        }
        if let token = oaut2TokenStorage.token {
            UIBlockingProgressHUD.show()
            fetchProfile(token: token)
        } else {
            let vc = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController")
            
            if let authViewController = vc as? AuthViewController {
                authViewController.delegate = self
                authViewController.modalPresentationStyle = .fullScreen
                present(authViewController, animated: true)
            }
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
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        guard let tabBarController = tabBarController as? TabBarController else {
            return
        }
        
        tabBarController.profileImageService = profileImageService
        tabBarController.profileService = profileService
        
        window.rootViewController = tabBarController
    }
    
    private func addLogoImageView() {
        let image = UIImage(named: "Launch")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        logoImageView = imageView
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 78),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }

}

// MARK: - AuthViewControllerDelegate
extension SplashScreenViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        self.fetchAuthToken(code)
    }
    
    private func fetchAuthToken(_ code: String) {
        oauth2Service.fetchAuthToken(withCode: code) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
                self.isAlreadyShown = true
            case .failure:
                UIBlockingProgressHUD.dismiss()
                let alert = AlertModel(title: "Что-то пошло не так(",
                                       message: "Не удалось войти в систему",
                                       buttonText: "OK")
                
                self.alertPresenter?.showAlert(model: alert)
                break
            }
            self.dismiss(animated: true)
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
                self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case.failure:
                UIBlockingProgressHUD.dismiss()
                let alert = AlertModel(title: "Что-то пошло не так(",
                                       message: "Не удалось войти в систему",
                                       buttonText: "OK")
                
                self.alertPresenter?.showAlert(model: alert)
                break
            }
        }
    }
}
