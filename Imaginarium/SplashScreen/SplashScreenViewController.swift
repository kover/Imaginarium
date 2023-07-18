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
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var alertPresenter: AlertPresenterProtocol!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "YP Black")
        
        addLogoImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        alertPresenter = AlertPresenter(delegate: self)
        
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
            fatalError("Invalid Configuration")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
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
                let alert = AlertModel(title: "Что-то пошло не так(",
                                       message: "Не удалось войти в систему",
                                       buttonText: "OK")
                
                alertPresenter?.showAlert(model: alert)
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
                let alert = AlertModel(title: "Что-то пошло не так(",
                                       message: "Не удалось войти в систему",
                                       buttonText: "OK")
                
                alertPresenter?.showAlert(model: alert)
                break
            }
        }
    }
}
