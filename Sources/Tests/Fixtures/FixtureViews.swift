//
//  FixtureViews.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 01.03.2021.
//  Copyright © 2021 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class NibHeaderFooterView: UICollectionReusableView, ModelTransfer {

    func update(with model: Int) {
        
    }
    
}

class WrongReuseIdentifierReusableView : NibHeaderFooterView {
    override var reuseIdentifier: String? { return "Bar" }
}

class ReactingHeaderFooterView : UICollectionReusableView, ModelTransfer
{
    var sectionIndex: Int?
    var model : String?
    var configureModel: String?
    
    func update(with model: String) {
        self.model = model
    }
}

class StoryboardCollectionReusableHeaderView: UICollectionReusableView, ModelTransfer {
    @IBOutlet weak var storyboardLabel: UILabel!
    func update(with model: String) {
        
    }
}

class StoryboardCollectionReusableFooterView: UICollectionReusableView, ModelTransfer {
    @IBOutlet weak var storyboardLabel: UILabel!
    func update(with model: String) {
        
    }
}

class NiblessHeaderFooterView : UICollectionReusableView, ModelTransfer
{
    func update(with model: Int) {
        
    }
}
