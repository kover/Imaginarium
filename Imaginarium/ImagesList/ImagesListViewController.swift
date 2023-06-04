//
//  ViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 31.05.2023.
//

import UIKit

class ImagesListViewController: UIViewController {

    let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBOutlet private var feedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        feedTableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
}

