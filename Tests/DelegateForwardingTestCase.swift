//
//  DelegateForwardingTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 31.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage
@testable import DTCollectionViewManager
import Nimble

class DelegateCollectionViewController: DTSupplementaryTestCollectionController, UICollectionViewDelegateFlowLayout {
    var headerHeightRequested = false
    var footerHeightRequested = false
    var delegateMethodCalled = false
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        headerHeightRequested = true
        return CGSize(width: 200, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        footerHeightRequested = true
        return CGSize(width: 200, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        delegateMethodCalled = true
        return CGSize(width: 20, height: 50)
    }
}

class DelegateForwardingTestCase: XCTestCase {
    
    var controller : DelegateCollectionViewController!
    
    override func setUp() {
        super.setUp()
        controller = DelegateCollectionViewController()
        controller.manager.startManagingWithDelegate(controller)
    }
    
    func testHeaderHeightIsRequested() {
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        let _ = controller.manager.collectionView(controller.collectionView!, layout: controller.collectionView!.collectionViewLayout, referenceSizeForHeaderInSection:0)
        expect(self.controller.headerHeightRequested).to(beTrue())
    }
    
    func testFooterHeightIsRequested() {
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        let _ = controller.manager.collectionView(controller.collectionView!, layout: controller.collectionView!.collectionViewLayout, referenceSizeForFooterInSection:0)
        expect(self.controller.footerHeightRequested).to(beTrue())
    }
    
    func testDelegateMethodIsCalled() {
        controller.manager.registerNiblessCellClass(NiblessCell.self)
        controller.manager.registerNiblessSupplementaryClass(NiblessHeaderFooterView.self, forKind: UICollectionElementKindSectionHeader)
        controller.manager.registerNiblessSupplementaryClass(NiblessHeaderFooterView.self, forKind: UICollectionElementKindSectionFooter)
        let section = SectionModel()
        section.collectionHeaderModel = 1
        section.collectionFooterModel = 2
        section.items = [1]
        controller.manager.memoryStorage.setSection(section, forSection: 0)
        
        controller.collectionView!.performBatchUpdates(nil, completion: nil)
        
        expect(self.controller.delegateMethodCalled).to(beTrue())
    }
}
