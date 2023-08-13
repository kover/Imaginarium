//
//  TabBarController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 18.07.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    var profileImageService: ProfileImageServiceProtocol? {
        didSet {
            guard let service = profileImageService,
                  let viewControllers = viewControllers,
                  let profileViewController = viewControllers[1] as? ProfileViewController,
                  let presenter = profileViewController.presenter as? ProfileViewPresenter
            else {
                return
            }
        presenter.profileImageService = service
        }
    }
    
    var profileService: ProfileServiceProtocol? {
        didSet {
            guard let service = profileService,
                  let viewControllers = viewControllers,
                  let profileViewController = viewControllers[1] as? ProfileViewController,
                  let presenter = profileViewController.presenter as? ProfileViewPresenter
            else {
                return
            }
            presenter.profileService = service
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        guard let imagesListViewController = imagesListViewController as? ImagesListViewController else {
            return
        }
        let imagesListPresenter = ImagesListPresenter()
        imagesListPresenter.imagesListService = ImagesListService()
        imagesListPresenter.helper = ImagesListHelper()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        let profileViewPresenter = ProfileViewPresenter()
        profileViewController.presenter = profileViewPresenter
        profileViewPresenter.view = profileViewController
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
