//
//  File.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

public extension SectionModel
{
    var collectionHeaderModel : Any? {
        get {
           return self.supplementaryModelOfKind(UICollectionElementKindSectionHeader)
        }
        set {
            self.setSupplementaryModel(newValue, forKind: UICollectionElementKindSectionHeader)
        }
    }
    
    var collectionFooterModel : Any? {
        get {
            return self.supplementaryModelOfKind(UICollectionElementKindSectionFooter)
        }
        set {
            self.setSupplementaryModel(newValue, forKind: UICollectionElementKindSectionFooter)
        }
    }
}