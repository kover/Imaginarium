//
//  ViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 31.05.2023.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var feedTableView: UITableView! { get }
    func presentAlert(_ controller: UIAlertController)
    func dismisAlert()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    var presenter: ImagesListPresenterProtocol?
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet var feedTableView: UITableView!
    
    // MARK: - Lifecycle and ViewController overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        feedTableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
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
        return presenter?.imageHeight(at: indexPath, for: tableView.bounds.width) ?? 0
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
