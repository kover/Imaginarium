//
//  AuthViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 28.06.2023.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let webViewSegueIdentifier = "ShowWebView"
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewSegueIdentifier {
            let viewController = segue.destination as! WebViewViewConroller
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - WebViewViewControllerDelegate implementation
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewConroller, didAuthenticateWithCode code: String) {
        OAuth2Service.shared.fetchAuthToken(withCode: code) { result in
            print(result)
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewConroller) {
        vc.dismiss(animated: true)
    }
    
    
}
