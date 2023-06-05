//
//  ImageListCell.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.06.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    private var favoriteFlag = true
    
    var isFavorite: Bool {
        set {
            favoriteFlag = newValue
            guard let image = favoriteFlag ? UIImage(named: "Liked") : UIImage(named: "Disliked") else {
                return
            }
            likeButton.setImage(image, for: .normal)
        }
        get {
            return favoriteFlag
        }
    }
    
    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        if let startColor = UIColor(named: "Gradient Start"), let stopColor = UIColor(named: "Gradient Stop") {
            gradient.colors = [
                startColor.cgColor,
                stopColor.cgColor
            ]
        }
        gradient.locations = [0, 0.53]
        return gradient
    }()
    
    @IBOutlet private var cellImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var postDate: UILabel!
    @IBOutlet private var gradientView: UIView!
    
    @IBAction func toggleLike() {
        isFavorite = !isFavorite
    }
    
    
    func setCellImage(_ image: UIImage) {
        cellImage.image = image
    }
    
    func setPostDate(_ date: String) {
        postDate.text = date
    }
    
    func addGradient() {
        gradient.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradient)
    }
    
}
