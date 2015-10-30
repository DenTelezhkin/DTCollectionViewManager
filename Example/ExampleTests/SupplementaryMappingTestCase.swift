//
//  SupplementaryMappingTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 30.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import Nimble
import DTModelStorage
import DTCollectionViewManager

class SupplementaryMappingTestCase: XCTestCase {
    
    var controller: DTSupplementaryTestCollectionController!
    
    override func setUp() {
        super.setUp()
        controller = DTSupplementaryTestCollectionController()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.viewBundle = NSBundle(forClass: self.dynamicType)
        controller.manager.memoryStorage.configureForCollectionViewFlowLayoutUsage()
//        let _ = controller.collectionView?.numberOfSections()
    }
    
    func testHeaderMappingFromHeaderFooterView()
    {
        controller.manager.registerHeaderClass(NibHeaderFooterView)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, atIndexPath:  indexPath(0, 0))
        expect(view).to(beAKindOf(NibHeaderFooterView.self))
    }
    
}
