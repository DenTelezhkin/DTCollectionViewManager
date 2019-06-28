//
//  DTTestCollectionController.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage
import DTCollectionViewManager

class DTCellTestCollectionController: UIViewController, DTCollectionViewManageable {

    var collectionView: UICollectionView! = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

}

class DTSupplementaryTestCollectionController: UIViewController, DTCollectionViewManageable {
    
    var collectionView : UICollectionView! = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768), collectionViewLayout: UICollectionViewFlowLayout())
}
