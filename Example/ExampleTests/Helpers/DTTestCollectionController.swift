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

    var collectionView: UICollectionView? = AlwaysVisibleCollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())

}

extension DTTestCollectionController : UICollectionViewDelegateFlowLayout
{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 200, height: 300)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 200, height: 300)
    }
}
