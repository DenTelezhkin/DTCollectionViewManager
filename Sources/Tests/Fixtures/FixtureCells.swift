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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class StringCell : UICollectionViewCell, ModelTransfer
{
    func update(with model: String) {
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class ReactingCollectionCell: UICollectionViewCell, ModelTransfer {
    func update(with model: Int) {
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class StoryboardCollectionViewCell: UICollectionViewCell, ModelTransfer {
    @IBOutlet weak var storyboardLabel: UILabel!
    func update(with model: Int) {
    }
}


class SelectionReactingCollectionCell: ReactingCollectionCell
{
    @IBOutlet weak var textLabel: UILabel!
    var indexPath: IndexPath?
    var cell: SelectionReactingCollectionCell?
    var model : Int?
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class IntCell : UICollectionViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class AnotherIntCell : UICollectionViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class ReusableCell: UICollectionViewCell, ModelTransfer {
    var updateCalledTimes: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func update(with model: Int) {
        updateCalledTimes += 1
    }
    
    var prepareForReuseCalledTimes: Int = 0
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareForReuseCalledTimes += 1
    }
}
