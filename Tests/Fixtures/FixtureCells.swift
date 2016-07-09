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
    
    func updateWithModel(_ model: Int) {
        self.model = model
    }
}

class NiblessCell: BaseTestCell {}

class NibCell: BaseTestCell {}

class StringCell : UICollectionViewCell, ModelTransfer
{
    func updateWithModel(_ model: String) {
        
    }
}

class ReactingCollectionCell: UICollectionViewCell, ModelTransfer {
    
    func updateWithModel(_ model: Int) {
        
    }
    
}

class SelectionReactingCollectionCell: ReactingCollectionCell
{
    @IBOutlet weak var textLabel: UILabel!
    var indexPath: IndexPath?
    var cell: SelectionReactingCollectionCell?
    var model : Int?
}
