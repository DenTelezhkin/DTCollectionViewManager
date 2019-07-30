//
//  SupplementaryMappingTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 30.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import DTCollectionViewManager

class SupplementaryMappingTestCase: XCTestCase {
    
    var controller: DTSupplementaryTestCollectionController!
    
    override func setUp() {
        super.setUp()
        controller = DTSupplementaryTestCollectionController()
        let _ = controller.view
        controller.manager.memoryStorage.configureForCollectionViewFlowLayoutUsage()
    }
    
    func verifyHeader() {
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: DTCollectionViewElementSectionHeader, at:  indexPath(0, 0))
        XCTAssertTrue(view is NibHeaderFooterView)
    }
    
    func verifyFooter() {
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: DTCollectionViewElementSectionFooter, at:  indexPath(0, 0))
        XCTAssertTrue(view is NibHeaderFooterView)
    }
    
    func testHeaderMappingFromHeaderFooterView()
    {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        verifyHeader()
    }
    
    func testFooterMappingFromHeaderFooterView()
    {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        verifyFooter()
    }
    
    func testRegisterNibNamedForHeaderClass()
    {
        controller.manager.registerNibNamed("RandomNameHeaderFooterView", forHeader: NibHeaderFooterView.self)
        verifyHeader()
    }
    
    func testRegisterNibNamedForFooterClass()
    {
        controller.manager.registerNibNamed("RandomNameHeaderFooterView", forFooter: NibHeaderFooterView.self)
        verifyFooter()
    }
    
    func testRegisterSupplementaryClassForKind()
    {
        controller.manager.registerSupplementary(NibHeaderFooterView.self, forKind: DTCollectionViewElementSectionFooter)
        verifyFooter()
    }
    
    func testRegisterNibNamedForSupplementaryClass()
    {
        controller.manager.registerNibNamed("RandomNameHeaderFooterView", forSupplementary: NibHeaderFooterView.self, ofKind: DTCollectionViewElementSectionFooter)
        verifyFooter()
    }
    
    func testRegisterNiblessSupplementaryClass() {
        controller.manager.registerNiblessSupplementary(NiblessHeaderFooterView.self, forKind: DTCollectionViewElementSectionHeader)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: DTCollectionViewElementSectionHeader, at:  indexPath(0, 0))
        XCTAssertTrue(view is NiblessHeaderFooterView)
    }
    
    func testRegisterNiblessHeader() {
        controller.manager.registerNiblessHeader(NiblessHeaderFooterView.self)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: DTCollectionViewElementSectionHeader, at:  indexPath(0, 0))
        XCTAssertTrue(view is NiblessHeaderFooterView)
    }
    
    func testRegisterNiblessFooter() {
        controller.manager.registerNiblessFooter(NiblessHeaderFooterView.self)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: DTCollectionViewElementSectionFooter, at:  indexPath(0, 0))
        XCTAssertTrue(view is NiblessHeaderFooterView)
    }
}
