//
//  DTTestCollectionController.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager

class DTCellTestCollectionController: UIViewController, DTCollectionViewManageable {

    var collectionView: UICollectionView? = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())

}

class DTSupplementaryTestCollectionController: UIViewController, DTCollectionViewManageable {
    
    var collectionView : UICollectionView? = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768), collectionViewLayout: UICollectionViewFlowLayout())
}

extension DTSupplementaryTestCollectionController : UICollectionViewDelegateFlowLayout
{
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: 200, height: 300)
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: 200, height: 300)
//    }
}
