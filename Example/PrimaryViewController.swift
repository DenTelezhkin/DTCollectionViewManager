//
//  PrimaryViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager

class PrimaryViewController: UICollectionViewController, DTCollectionViewManageable {
    
    convenience init() {
        self.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: .init(appearance: .sidebarPlain)))
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.register(UICollectionViewListCell.self, for: Example.self) { [weak self] mapping in
            mapping.didSelect { _, example, _ in
                let controller = example.controller
                self?.splitViewController?.setViewController(controller, for: .secondary)
                self?.splitViewController?.show(.secondary)
            }
        } handler: { cell, model, _ in
            var content = cell.defaultContentConfiguration()
            content.text = model.title
            cell.contentConfiguration = content
        }
        manager.memoryStorage.setItems(Example.allCases)
    }
}
