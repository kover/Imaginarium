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
    
    @IBOutlet private var cellImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var postDate: UILabel!
    @IBOutlet private var gradientView: UIView!
    
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
    func configureCell(usingPhoto photo: Photo, completion: @escaping () -> Void) {
        guard let date = photo.createdAt else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        postDate.text = dateFormatter.string(from: date)
        
        isFavorite = photo.isLiked
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "Stub")
        ) { _ in
            completion()
        }
        
        gradient.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradient)
    }
}
