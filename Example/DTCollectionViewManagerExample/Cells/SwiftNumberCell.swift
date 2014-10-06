//
//  SwiftNumberCell.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 06.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

class SwiftNumberCell: DTCollectionViewCell, DTModelTransfer {

    @IBOutlet weak var numberLabel: UILabel!
    override func updateWithModel(model: AnyObject!) {
        self.numberLabel.text = (model as NSNumber).stringValue
        self.backgroundColor = UIColor.dt_randomColor()
    }
}
