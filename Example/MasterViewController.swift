//
//  MasterViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager

class MasterViewController: UICollectionViewController, DTCollectionViewManageable {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.register(UICollectionViewListCell.self, for: Example.self, handler: { cell, model, _ in
            var content = cell.defaultContentConfiguration()
            content.text = model.title
            cell.contentConfiguration = content
        }) { [weak self] mapping in
            mapping.didSelect { _, example, _ in
                let controller = example.controller
                controller.navigationItem.hidesBackButton = true
                self?.splitViewController?.setViewController(controller, for: .secondary)
            }
        }
        manager.memoryStorage.setItems(Example.allCases)
    }
}

