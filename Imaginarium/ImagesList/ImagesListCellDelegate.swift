//
//  ImagesListCellDelegate.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 26.07.2023.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
