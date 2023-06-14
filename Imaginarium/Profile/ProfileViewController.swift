//
//  ProfileViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 08.06.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private var profilePictureImageView: UIImageView!
    @IBOutlet private var fullNameLabel: UILabel!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var profileDescriptionLabel: UILabel!
    
    @IBOutlet private var logoutButton: UIButton!
    
    @IBAction private func logoutTap() {}
}
