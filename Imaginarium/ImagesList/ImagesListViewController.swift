//
//  ViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 31.05.2023.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    func presentAlert(_ controller: UIAlertController)
    func dismisAlert()
    func insertRows(from start: Int, to end: Int)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    var presenter: ImagesListPresenterProtocol?
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var feedTableView: UITableView!
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
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
                self.presenter?.updateTableViewAnimated()
            }
        
        presenter?.loadNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier,
            let viewController = segue.destination as? SingleImageViewController
        {
            let indexPath = sender as! IndexPath
            let photo = presenter?.photos[indexPath.row]
            viewController.photo = photo
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func presentAlert(_ controller: UIAlertController) {
        present(controller, animated: true)
    }
    
    func dismisAlert() {
        dismiss(animated: true)
    }
    
    func insertRows(from start: Int, to end: Int) {
        feedTableView.performBatchUpdates {
            feedTableView.insertRows(at: (start..<end).map { index in
                IndexPath(row: index, section: 0)
            }, with: .automatic)
        }
    }
}

// MARK: - Table View Data Source extension
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        presenter?.configure(cell: imageListCell, for: indexPath)

        return imageListCell
    }
}

// MARK: - Table View Delegate extension
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = presenter?.photos[indexPath.row] else {
            return 0
        }
        let imageSize = image.size
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == presenter?.photosCount {
            presenter?.loadNextPage()
        }
    }
}

// MARK: - Images List Cell Delegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = feedTableView.indexPath(for: cell) else {
            return
        }
        self.presenter?.changeLike(at: indexPath, for: cell)
    }
}
