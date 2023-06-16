//
//  ProfileViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 08.06.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    private var profilePictureImageView: UIImageView!
    private var fullNameLabel: UILabel!
    private var userNameLabel: UILabel!
    private var profileDescriptionLabel: UILabel!
    
    private var logoutButton: UIButton!
    
    @objc private func logoutTap() {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addProfileImageView()
        addFullNameLabel()
        addUserNameLabel()
        addDescriptionLabel()
        addLogoutButton()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
