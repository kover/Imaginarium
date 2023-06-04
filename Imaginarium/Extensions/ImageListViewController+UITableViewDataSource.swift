//
//  ImageListViewController+UITableViewDataSource.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 03.06.2023.
//

import UIKit

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configureCell(for: imageListCell, with: indexPath)
        return imageListCell
    }

    
    
}
