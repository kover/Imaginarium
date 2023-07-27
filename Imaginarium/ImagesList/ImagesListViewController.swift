//
//  ViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 31.05.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    var imagesListService: ImagesListServiceProtocol?
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let photosName: [String] = Array(0..<22).map{ "\($0)" }
    private var photos: [Photo] = []
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBOutlet private var feedTableView: UITableView!
    
    // MARK: - Lifecycle and ViewController overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        feedTableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.updateTableViewAnimated()
            }
        
        imagesListService?.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let photo = photos[indexPath.row]
            viewController.photo = photo
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Table View Data Source extension
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        imageListCell.configureCell(usingPhoto: photos[indexPath.row]) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        return imageListCell
    }
}

// MARK: - Table View Delegate extension
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSize = photos[indexPath.row].size
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService?.photos.count {
            imagesListService?.fetchPhotosNextPage()
        }
    }
}

// MARK: - Table update
extension ImagesListViewController {
    func updateTableViewAnimated() {
        guard let imagesListService = imagesListService else {
            return
        }
        let currentCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if currentCount == newCount {
            return
        }
        
        feedTableView.performBatchUpdates {
            feedTableView.insertRows(at: (currentCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }, with: .automatic)
        }

    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = feedTableView.indexPath(for: cell) else {
            return
        }
        let photo  = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService?.changeLike(photoId: photo.id, isLike: !photo.isLiked, { result in
            switch result {
            case .success:
                if let servicePhotos = self.imagesListService?.photos {
                    self.photos = servicePhotos
                }
                cell.setIsLiked(isLiked: !photo.isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                // TODO: Handle error
            }
        })
    }
}
