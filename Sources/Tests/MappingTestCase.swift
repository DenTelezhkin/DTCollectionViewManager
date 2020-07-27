//
//  MappingTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTCollectionViewManager

class MappingTestCase: XCTestCase {
    
    var controller = DTCellTestCollectionController()
    
    override func setUp() {
        super.setUp()
        let _ = controller.view
    }
    
    func testRegistrationWithDifferentNibName()
    {
        controller.manager.register(NibCell.self) { mapping in
            mapping.xibName = "RandomNibNameCell"
        }
        
        controller.manager.memoryStorage.addItem(3)
        
        XCTAssert(controller.verifyItem(3, atIndexPath: indexPath(0,0)))
    }
    
    func testOptionalUnwrapping()
    {
        controller.manager.register(NibCell.self)
        
        let intOptional : Int? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        XCTAssert(controller.verifyItem(3, atIndexPath: indexPath(0, 0)))
    }
    
    func testSeveralLevelsOfOptionalUnwrapping()
    {
        controller.manager.register(NibCell.self)
        
        let intOptional : Int?? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        XCTAssert(controller.verifyItem(3, atIndexPath: indexPath(0, 0)))
    }
    
    func testNiblessMapping()
    {
        controller.manager.register(StringCell.self)
        controller.manager.memoryStorage.addItem("foo")
        
        XCTAssertEqual(controller.manager.memoryStorage.item(at: indexPath(0, 0)) as? String, "foo")
    }
    
    func testUnregisterCellClass() {
        controller.manager.register(NibCell.self)
        controller.manager.unregister(NibCell.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 0)
    }
    
    func testUnregisterHeaderClass() {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibHeaderFooterView.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 0)
    }
    
    func testUnregisterFooterClass() {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.unregisterFooter(NibHeaderFooterView.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 0)
    }
    
    func testUnregisterHeaderClassDoesNotUnregisterCell() {
        controller.manager.register(NibCell.self)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibCell.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 2)
    }
    
    func testUnregisteringHeaderDoesNotUnregisterFooter() {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibHeaderFooterView.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 1)
    }
    
    
    func testTwoKindsOfCellRegistrationsAreCombinable() {
        controller.manager.register(NibCell.self)
        controller.manager.register(UICollectionViewCell.self, for: String.self, handler: { cell, model, _ in
            let label = UILabel()
            label.text = model
            cell.backgroundView = label
        })
        controller.manager.memoryStorage.addItem(1)
        controller.manager.memoryStorage.addItem("Foo")
        
        XCTAssertEqual(controller.manager.collectionDataSource?.collectionView(controller.collectionView, numberOfItemsInSection: 0), 2)
        _ = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0))
        let cvCell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(1,0))
        
        XCTAssertEqual((cvCell?.backgroundView as? UILabel)?.text, "Foo")
    }

    func testTwoKindsOfHeaderRegistrationsAreCombinable() {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.registerHeader(UICollectionReusableView.self, for: String.self, handler: { view, model, _ in
            let label = UILabel()
            label.text = model
            view.addSubview(label)
        })
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.headerModelProvider = { section in
            if section == 0 {
                return 1
            } else {
                return "2"
            }
        }
        controller.manager.memoryStorage.setItemsForAllSections([[1], [2]])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        let nibView = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 0))
        let cvView = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 1))
        XCTAssertTrue(nibView is NibHeaderFooterView)
        XCTAssertEqual((cvView?.subviews.first as? UILabel)?.text, "2")
    }
    
    func testTwoKindsOfFooterRegistrationsAreCombinable() {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.registerFooter(UICollectionReusableView.self, for: String.self, handler: { view, model, _ in
            let label = UILabel()
            label.text = model
            view.addSubview(label)
        })
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.footerModelProvider = { section in
            if section == 0 {
                return 1
            } else {
                return "2"
            }
        }
        controller.manager.memoryStorage.setItemsForAllSections([[1], [2]])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        let nibView = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at:  indexPath(0, 0))
        let cvView = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at:  indexPath(0, 1))
        XCTAssertTrue(nibView is NibHeaderFooterView)
        XCTAssertEqual((cvView?.subviews.first as? UILabel)?.text, "2")
    }
}

class NibNameViewModelMappingTestCase : XCTestCase {
    var factory : CollectionViewFactory!
    
    override func setUp() {
        super.setUp()
        factory = CollectionViewFactory(collectionView: UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout()))
    }
    
    func testCellWithXibHasXibNameInMapping() {
        factory.registerCellClass(NibCell.self, handler: { _,_,_ in }, mapping: nil)
        
        XCTAssertEqual(factory.mappings.first?.xibName, "NibCell")
    }
    
    func testHeaderHasXibInMapping() {
        factory.registerSupplementaryClass(NibHeaderFooterView.self, ofKind: UICollectionView.elementKindSectionHeader, handler: { _,_,_ in }, mapping: nil)
        
        XCTAssertEqual(factory.mappings.first?.xibName, "NibHeaderFooterView")
    }
    
    func testFooterHasXibInMapping() {
        factory.registerSupplementaryClass(NibHeaderFooterView.self, ofKind: UICollectionView.elementKindSectionFooter, handler: { _,_,_ in } , mapping: nil)
        
        XCTAssertEqual(factory.mappings.first?.xibName, "NibHeaderFooterView")
    }
}
