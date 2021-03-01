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
    
    func testMappingCanBeSwitchedBetweenSections() {
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .section(0)
        }
        controller.manager.register(AnotherIntCell.self) { mapping in
            mapping.condition = .section(1)
        }
        
        controller.manager.memoryStorage.addItem(1)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        let nibCell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0))
        XCTAssert(nibCell is NibCell)
        
        let cell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,1))
        
        XCTAssert(cell is AnotherIntCell)
    }
    
    func testCustomMappingIsRevolvableForTheSameModel() {
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .custom({ indexPath, model in
                guard let model = model as? Int else { return false }
                return model > 2
            })
        }
        controller.manager.register(AnotherIntCell.self) { mapping in
            mapping.condition = .custom({ indexPath, model -> Bool in
                guard let model = model as? Int else { return false }
                return model <= 2
            })
        }
        
        controller.manager.memoryStorage.addItem(3)
        let cell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0))
        XCTAssert(cell is NibCell)
        
        controller.manager.memoryStorage.addItem(1)
        let anotherCell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(1,0))
        XCTAssert(anotherCell is AnotherIntCell)
    }
    
    func testMappingCanBeSwitchedForNibNames() {
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .section(0)
            mapping.reuseIdentifier = "NibCell One"
        }
        controller.manager.register(NibCell.self) { mapping in
            mapping.xibName = "CustomNibCell"
            mapping.condition = .section(1)
            mapping.reuseIdentifier = "NibCell Two"
        }
        
        controller.manager.memoryStorage.addItem(1)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        
        let nibCell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0)) as? NibCell
        XCTAssertNil(nibCell?.customLabel)
        
        let customNibCell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,1)) as? NibCell
        
        XCTAssertNotNil(customNibCell?.customLabel)
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

class StoryboardMappingTestCase: XCTestCase {
    
    var controller : StoryboardViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "FixtureStoryboard", bundle: Bundle(for: type(of: self)))
        controller = storyboard.instantiateInitialViewController() as? StoryboardViewController
        _ = controller.view
    }
    
    func testStoryboardCellIsCreatedAndOutletsAreWired() {
        controller.manager.register(StoryboardCollectionViewCell.self) {
            $0.cellRegisteredByStoryboard = true
        }
        controller.manager.memoryStorage.addItem(3)
        
        let cell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0, 0)) as? StoryboardCollectionViewCell
        
        XCTAssertNotNil(cell?.storyboardLabel)
    }
    
    func testSupplementaryHeadersAreRegisteredAndOutletsAreWired() {
        controller.manager.registerHeader(StoryboardCollectionReusableHeaderView.self) {
            $0.supplementaryRegisteredByStoryboard = true
        }
        controller.manager.registerFooter(StoryboardCollectionReusableFooterView.self) {
            $0.supplementaryRegisteredByStoryboard = true
        }
        
        
        controller.manager.memoryStorage.setSectionHeaderModels(["1"])
        controller.manager.memoryStorage.setSectionFooterModels(["2"])
        controller.manager.memoryStorage.setItems([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let headerView = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 0)) as? StoryboardCollectionReusableHeaderView
        
        let footerView = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at:  indexPath(0, 0)) as? StoryboardCollectionReusableFooterView
        
        XCTAssertEqual(headerView?.storyboardLabel.text, "Header")
        XCTAssertEqual(footerView?.storyboardLabel.text, "Footer")
    }
}

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
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 0))
        XCTAssertTrue(view is NibHeaderFooterView)
    }
    
    func verifyFooter() {
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at:  indexPath(0, 0))
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
        controller.manager.registerHeader(NibHeaderFooterView.self) { mapping in
            mapping.xibName = "RandomNameHeaderFooterView"
        }
        verifyHeader()
    }
    
    func testRegisterNibNamedForFooterClass()
    {
        controller.manager.registerFooter(NibHeaderFooterView.self) { mapping in
            mapping.xibName = "RandomNameHeaderFooterView"
        }
        verifyFooter()
    }
    
    func testRegisterSupplementaryClassForKind()
    {
        controller.manager.registerSupplementary(NibHeaderFooterView.self, ofKind: UICollectionView.elementKindSectionFooter)
        verifyFooter()
    }
    
    func testRegisterNibNamedForSupplementaryClass()
    {
        controller.manager.registerSupplementary(NibHeaderFooterView.self, ofKind: UICollectionView.elementKindSectionFooter) { mapping in
            mapping.xibName = "RandomNameHeaderFooterView"
        }
        verifyFooter()
    }
    
    func testRegisterNiblessSupplementaryClass() {
        controller.manager.registerSupplementary(NiblessHeaderFooterView.self, ofKind: UICollectionView.elementKindSectionHeader)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 0))
        XCTAssertTrue(view is NiblessHeaderFooterView)
    }
    
    func testRegisterNiblessHeader() {
        controller.manager.registerHeader(NiblessHeaderFooterView.self)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 0))
        XCTAssertTrue(view is NiblessHeaderFooterView)
    }
    
    func testRegisterNiblessFooter() {
        controller.manager.registerFooter(NiblessHeaderFooterView.self)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at:  indexPath(0, 0))
        XCTAssertTrue(view is NiblessHeaderFooterView)
    }
    
    func testSettingReuseIdentifierCrashesApplication() throws {
        let exp = expectation(description: "expected result")
        controller.manager.register(NibCell.self) {
            $0.xibName = "NibReuseIdentifier"
        }
        SwiftTryCatch.try {
            self.controller.manager.memoryStorage.addItem(1)
            if #available(iOS 14, tvOS 14, *) {
                
            } else {
                // This is not expected to crash on iOS < 14
                exp.fulfill()
            }
        } catch: { exception in
            XCTAssert(exception.reason?.contains("view reuse identifier in nib (NibCell) does not match the identifier used to register the nib") ?? false)
            
            // iOS 14+, reuse identifier taken from UICollectionView.CellRegistration instead of xib
            exp.fulfill()
        } finallyBlock: {
            
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}
