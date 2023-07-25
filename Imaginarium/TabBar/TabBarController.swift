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
                    let profileViewController = viewControllers[1] as? ProfileViewController
            else {
                return
            }
            profileViewController.profileImageService = service
        }
    }
    
    var profileService: ProfileServiceProtocol? {
        didSet {
            guard let service = profileService,
                  let viewControllers = viewControllers,
                  let profileViewController = viewControllers[1] as? ProfileViewController
            else {
                return
            }
            profileViewController.profileService = service
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        guard let imagesListViewController = imagesListViewController as? ImagesListViewController else {
            return
        }
        imagesListViewController.imageListService = ImagesListService()
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
