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
        controller.manager.memoryStorage.configureForCollectionViewFlowLayoutUsage()
    }
    
    func verifyHeader() {
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, atIndexPath:  indexPath(0, 0))
        expect(view).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func verifyFooter() {
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionFooter, atIndexPath:  indexPath(0, 0))
        expect(view).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func testHeaderMappingFromHeaderFooterView()
    {
        controller.manager.registerHeaderClass(NibHeaderFooterView)
        verifyHeader()
    }
    
    func testFooterMappingFromHeaderFooterView()
    {
        controller.manager.registerFooterClass(NibHeaderFooterView)
        verifyFooter()
    }
    
    func testRegisterNibNamedForHeaderClass()
    {
        controller.manager.registerNibNamed("RandomNameHeaderFooterView", forHeaderClass: NibHeaderFooterView.self)
        verifyHeader()
    }
    
    func testRegisterNibNamedForFooterClass()
    {
        controller.manager.registerNibNamed("RandomNameHeaderFooterView", forFooterClass: NibHeaderFooterView.self)
        verifyFooter()
    }
    
    func testRegisterSupplementaryClassForKind()
    {
        controller.manager.registerSupplementaryClass(NibHeaderFooterView.self, forKind: UICollectionElementKindSectionFooter)
        verifyFooter()
    }
    
    func testRegisterNibNamedForSupplementaryClass()
    {
        controller.manager.registerNibNamed("RandomNameHeaderFooterView", supplementaryClass: NibHeaderFooterView.self, forKind: UICollectionElementKindSectionFooter)
        verifyFooter()
    }
    
    func testRegisterNiblessSupplementaryClass() {
        controller.manager.registerNiblessSupplementaryClass(NiblessHeaderFooterView.self, forKind: UICollectionElementKindSectionHeader)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, atIndexPath:  indexPath(0, 0))
        expect(view).to(beAKindOf(NiblessHeaderFooterView.self))
    }
}
