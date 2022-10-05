//
//  PrimaryViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager
import SwiftUI

class PrimaryViewController: UICollectionViewController, DTCollectionViewManageable {
    
    convenience init() {
        self.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: .init(appearance: .sidebarPlain)))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.registerHostingConfiguration(for: Example.self, cell: UICollectionViewListCell.self) { cell, model, indexPath in
            UIHostingConfiguration {
                HStack {
                    Text(model.title)
                    Spacer()
                }
            }
        } mapping: { [weak self] in
            $0.didSelect { _, example, _ in
                let controller = example.controller
                self?.splitViewController?.setViewController(controller, for: .secondary)
                self?.splitViewController?.show(.secondary)
            }
        }
        manager.memoryStorage.setItems(Example.allCases)
    }
}
