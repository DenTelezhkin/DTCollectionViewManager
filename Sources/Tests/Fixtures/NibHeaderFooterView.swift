//
//  NibHeaderFooterVIew.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
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
