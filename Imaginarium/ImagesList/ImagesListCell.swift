//
//  ImageListCell.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.06.2023.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    private var isFavorite: Bool = false {
        didSet {
            guard let image = isFavorite ? UIImage(named: "Liked") : UIImage(named: "Disliked") else {
                return
            }
            likeButton.setImage(image, for: .normal)
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
    
    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var postDate: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    
    @IBAction func toggleLike() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        cellImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(isLiked: Bool) {
        isFavorite = isLiked
    }
    
}

// MARK: - Cell configuration extension
extension ImagesListCell {
    func configureCell(forPhoto url: String, postedAt createdAt: String, liked: Bool, completion: @escaping () -> Void) {
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage(named: "Stub")
        ) { _ in
            completion()
        }
        
        postDate.text = createdAt
        
        isFavorite = liked
        
        gradient.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradient)
    }
}
