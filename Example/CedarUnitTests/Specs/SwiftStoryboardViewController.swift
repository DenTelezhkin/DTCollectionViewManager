//
//  SwiftStoryboardViewController.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 02.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

class SwiftStoryboardViewController: DTCollectionViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerCellClass(SwiftCollectionViewCell.self, forModelClass: NSString.self)
        self.registerSupplementaryClass(SwiftHeaderView.self,
            forKind: UICollectionElementKindSectionHeader,
            forModelClass: NSString.self)
        
        self.registerSupplementaryClass(SwiftHeaderView.self,
                                        forKind: UICollectionElementKindSectionFooter,
                                        forModelClass: NSString.self)
    }
}
