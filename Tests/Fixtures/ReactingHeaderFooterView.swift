//
//  ReactingHeaderFooterView.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class ReactingHeaderFooterView : UICollectionReusableView, ModelTransfer
{
    var sectionIndex: Int?
    var model : String?
    
    func updateWithModel(_ model: String) {
        self.model = model
    }
}
