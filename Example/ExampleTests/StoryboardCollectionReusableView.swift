//
//  StoryboardCollectionReusableView.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 10.01.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class StoryboardCollectionReusableHeaderView: UICollectionReusableView, ModelTransfer {
    @IBOutlet weak var storyboardLabel: UILabel!
    func updateWithModel(model: String) {
        
    }
}

class StoryboardCollectionReusableFooterView: UICollectionReusableView, ModelTransfer {
    @IBOutlet weak var storyboardLabel: UILabel!
    func updateWithModel(model: String) {
        
    }
}
