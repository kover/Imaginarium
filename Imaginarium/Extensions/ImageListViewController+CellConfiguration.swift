//
//  ImageListViewController+CellConfiguration.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 05.06.2023.
//

import UIKit

extension ImagesListViewController {
    func configureCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        cell.setCellImage(image)
        
        cell.setPostDate(dateFormatter.string(from: Date()))

        cell.isFavorite = indexPath.row % 2 == 0
        
        cell.addGradient()
    }
}
