//
//  ImageListCell.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.06.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    private var _isFavorite = true
    
    var isFavorite: Bool {
        set {
            _isFavorite = newValue
            guard let image = _isFavorite ? UIImage(named: "Liked") : UIImage(named: "Disliked") else {
                return
            }
            likeButton.setImage(image, for: .normal)
        }
        get {
            return _isFavorite
        }
    }
    
    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor(named: "Gradient Start")!.cgColor,
            UIColor(named: "Gradient Stop")!.cgColor
        ]
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
