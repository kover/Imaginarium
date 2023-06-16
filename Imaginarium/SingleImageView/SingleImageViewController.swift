//
//  SingleImageViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 13.06.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else {
                return
            }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Lifecycle and ViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        imageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Actions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @IBAction private func didTapShareButton() {
        guard let image = image else {
            return
        }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    // MARK: - Scaling logic
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        // Get current scale bounds
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        // Get scrollView and image boundaries
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        // Calculate horizontal and vertical scale
        let horizontalScale = visibleRectSize.width / imageSize.width
        let verticalScale = visibleRectSize.height / imageSize.height
        // Calculate final scale value
        let scale = min(maxZoomScale, max(minZoomScale, max(horizontalScale, verticalScale)))
        // Set scale and re-layout the view
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        // Grab new content size
        let newContentSize = scrollView.contentSize
        // Calculate origin to center content
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        // Center content in scroll view

        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate methods
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
