//
//  AlertPresenter.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 13.07.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
}

protocol AlertPresenterProtocol {
    func showAlert(model: AlertModel)
}

class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        guard let delegate = delegate else {
            return
        }
        
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "ImaginariumAlert"
        
        let action = UIAlertAction(title: model.buttonText, style: .default)
        
        alert.addAction(action)
        
        delegate.present(alert, animated: true, completion: nil)
    }
}
