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
}
