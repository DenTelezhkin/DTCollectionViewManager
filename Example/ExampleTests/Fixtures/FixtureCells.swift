//
//  FixtureCells.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

class BaseTestCell : UICollectionViewCell, ModelTransfer, ModelRetrievable
{
    var model : Any!
    var awakedFromNib = false
    var inittedWithStyle = false
    
    func updateWithModel(model: Int) {
        self.model = model
    }
}

class NiblessCell: BaseTestCell {}

class NibCell: BaseTestCell {}

class StringCell : UICollectionViewCell, ModelTransfer
{
    func updateWithModel(model: String) {
        
    }
}

class ReactingCollectionCell: UICollectionViewCell, ModelTransfer {
    
    func updateWithModel(model: Int) {
        
    }
    
}

class SelectionReactingTableCell: ReactingCollectionCell
{
    var indexPath: NSIndexPath?
    var cell: SelectionReactingTableCell?
    var model : Int?
}