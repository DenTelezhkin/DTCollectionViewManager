//
//  DTTestCollectionController.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager

class DTTestCollectionController: UIViewController, DTCollectionViewManageable {

    var collectionView: UICollectionView! = AlwaysVisibleCollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())

}
