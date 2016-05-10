//
//  SimpleTextCollectionReusableView.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class SimpleTextCollectionReusableView: UICollectionReusableView, ModelTransfer {

    @IBOutlet weak var title: UILabel!
    
    func updateWithModel(model: String) {
        title.text = model
    }
    
}
