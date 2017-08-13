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
        controller.manager.startManaging(withDelegate: controller)
        controller.manager.memoryStorage.configureForCollectionViewFlowLayoutUsage()
    }
    
    func verifyHeader() {
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, at:  indexPath(0, 0))
        expect(view).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func verifyFooter() {
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionFooter, at:  indexPath(0, 0))
        expect(view).to(beAKindOf(NibHeaderFooterView.self))
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
        controller.manager.registerSupplementary(NibHeaderFooterView.self, forKind: UICollectionElementKindSectionFooter)
        verifyFooter()
    }
    
    func testRegisterNibNamedForSupplementaryClass()
    {
        controller.manager.registerNibNamed("RandomNameHeaderFooterView", forSupplementary: NibHeaderFooterView.self, ofKind: UICollectionElementKindSectionFooter)
        verifyFooter()
    }
    
    func testRegisterNiblessSupplementaryClass() {
        controller.manager.registerNiblessSupplementary(NiblessHeaderFooterView.self, forKind: UICollectionElementKindSectionHeader)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, at:  indexPath(0, 0))
        expect(view).to(beAKindOf(NiblessHeaderFooterView.self))
    }
    
    func testRegisterNiblessHeader() {
        controller.manager.registerNiblessHeader(NiblessHeaderFooterView.self)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, at:  indexPath(0, 0))
        expect(view).to(beAKindOf(NiblessHeaderFooterView.self))
    }
    
    func testRegisterNiblessFooter() {
        controller.manager.registerNiblessFooter(NiblessHeaderFooterView.self)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionFooter, at:  indexPath(0, 0))
        expect(view).to(beAKindOf(NiblessHeaderFooterView.self))
    }
}
