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
    
    func update(with model: Int) {
        self.model = model
    }
}

class NiblessCell: BaseTestCell {}

class NibCell: BaseTestCell {
    @IBOutlet weak var customLabel: UILabel?
}

class StringCell : UICollectionViewCell, ModelTransfer
{
    func update(with model: String) {
        
    }
}

class ReactingCollectionCell: UICollectionViewCell, ModelTransfer {
    
    func update(with model: Int) {
        
    }
    
}

class SelectionReactingCollectionCell: ReactingCollectionCell
{
    @IBOutlet weak var textLabel: UILabel!
    var indexPath: IndexPath?
    var cell: SelectionReactingCollectionCell?
    var model : Int?
}

class WrongReuseIdentifierCell : BaseTestCell {
    override var reuseIdentifier: String? { return "Foo" }
}
