//
//  ImagesListHelper.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 13.08.2023.
//

import UIKit

protocol ImagesListHelperProtocol {
    func showError(message: String, retryAction: UIAlertAction?, cancelAction: UIAlertAction?) -> UIAlertController
}

final class ImagesListHelper: ImagesListHelperProtocol {
    func showError(message: String, retryAction: UIAlertAction?, cancelAction: UIAlertAction?) -> UIAlertController {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        
        if let cancelAction = cancelAction {
            alert.addAction(cancelAction)
        }
        
        if let retryAction = retryAction {
            alert.addAction(retryAction)
        }
        
        return alert
    }
    
}
