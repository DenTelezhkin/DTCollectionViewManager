//
//  CollectionContainingCell.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 06.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager
import DTModelStorage

class CollectionContainingCell: UICollectionViewCell, DTCollectionViewManageable, ModelTransfer {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    func update(with model: Int) {
        let itemsArray = (1...model).map { _ in return randomColor() }
        self.manager.memoryStorage.setItems(itemsArray, forSection: 0)
    }
    
    override func awakeFromNib() {
        self.manager.startManaging(withDelegate: self)
        self.manager.register(SolidColorCollectionCell.self)
    }
}
