//
//  SolidColorCollectionCell.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class SolidColorCollectionCell: UICollectionViewCell, ModelTransfer {

    func updateWithModel(model: UIColor) {
        self.backgroundColor = model
    }

}
