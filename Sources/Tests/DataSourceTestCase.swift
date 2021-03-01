//
//  DataSourceTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTCollectionViewManager

class DataSourceTestCase: XCTestCase {
    
    var controller = DTCellTestCollectionController()
    
    override func setUp() {
        super.setUp()
        let _ = controller.view
        controller.manager.register(NibCell.self)
    }
    
    func testCollectionItemAtIndexPath()
    {
        controller.manager.memoryStorage.addItem(3)
        controller.manager.memoryStorage.addItems([2,1,6,4], toSection: 0)
        
        XCTAssert(self.controller.verifyItem(6, atIndexPath: indexPath(3, 0)))
        XCTAssert(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0)))
        XCTAssertNil(controller.manager.memoryStorage.item(at: indexPath(56, 0)))
    }
    
    func testShouldReturnCorrectNumberOfCollectionItems()
    {
        controller.manager.memoryStorage.addItems([1,1,1,1], toSection: 0)
        controller.manager.memoryStorage.addItems([2,2,2], toSection: 1)
        let collectionView = controller.collectionView
        XCTAssertEqual(controller.manager.collectionDataSource?.collectionView(collectionView!, numberOfItemsInSection: 0), 4)
        XCTAssertEqual(controller.manager.collectionDataSource?.collectionView(collectionView!, numberOfItemsInSection: 1), 3)
    }
    
    func testShouldReturnCorrectNumberOfSections()
    {
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        controller.manager.memoryStorage.addItem(4, toSection: 3)
        controller.manager.memoryStorage.addItem(2, toSection: 2)
        
        XCTAssertEqual(controller.manager.collectionDataSource?.numberOfSections(in: controller.collectionView!), 4)
    }
    
    func testShouldAddItems()
    {
        controller.manager.memoryStorage.addItems([3,2], toSection: 0)
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 2)
    }
    
    func testShouldInsertItem()
    {
        controller.manager.memoryStorage.addItems([2,4,6], toSection: 0)
        try! controller.manager.memoryStorage.insertItem(1, to: indexPath(2, 0))
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 4)
        XCTAssert(controller.verifyItem(1, atIndexPath: indexPath(2, 0)))
        XCTAssert(self.controller.verifyItem(6, atIndexPath: indexPath(3, 0)))
    }
    
    func testReplaceItem()
    {
        controller.manager.memoryStorage.addItems([1,3], toSection: 0)
        controller.manager.memoryStorage.addItems([4,6], toSection: 1)
        try! controller.manager.memoryStorage.replaceItem(3, with: 2)
        try! controller.manager.memoryStorage.replaceItem(4, with: 5)
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 2)
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 1)?.count, 2)
        XCTAssert(controller.verifyItem(2, atIndexPath: indexPath(1, 0)))
        XCTAssert(controller.verifyItem(5, atIndexPath: indexPath(0, 1)))
    }
    
    func testRemoveItem()
    {
        controller.manager.memoryStorage.addItems([1,3,2,4], toSection: 0)
        controller.manager.memoryStorage.removeItems([1,4,3,5])
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 1)
        XCTAssert(controller.verifyItem(2, atIndexPath: indexPath(0, 0)))
    }
    
    func testRemoveItems()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.setItems([Int](), forSection: 0)
        
        XCTAssertEqual(controller.manager.memoryStorage.items(inSection: 0)?.count, 0)
    }
    
    func testMovingItems()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.moveItem(at: indexPath(0, 0), to: indexPath(2, 0))
        
        XCTAssert(controller.verifySection([2,3,1], withSectionNumber: 0))
    }
    
    func testShouldNotCrashWhenMovingToBadRow()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        
        controller.manager.memoryStorage.moveItem(at: indexPath(0, 0), to: indexPath(2, 1))
    }
    
    func testShouldNotCrashWhenMovingFromBadRow()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.moveItem(at: indexPath(0, 1), to: indexPath(0, 0))
    }
    
    func testShouldMoveSections()
    {
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        controller.manager.memoryStorage.addItem(3, toSection: 2)
        
        controller.manager.memoryStorage.moveSection(0, toSection: 1)
        
        XCTAssert(controller.verifySection([2], withSectionNumber: 0))
        XCTAssert(controller.verifySection([1], withSectionNumber: 1))
        XCTAssert(controller.verifySection([3], withSectionNumber: 2))
    }
    
    func testShouldDeleteSections()
    {
        controller.manager.memoryStorage.addItem(0, toSection: 0)
        controller.manager.memoryStorage.addItem(1, toSection: 1)
        controller.manager.memoryStorage.addItem(2, toSection: 2)
        
        controller.manager.memoryStorage.deleteSections(IndexSet(integer: 1))
        
        XCTAssertEqual(controller.manager.memoryStorage.sections.count, 2)
        XCTAssert(controller.verifySection([2], withSectionNumber: 1))
    }
    
    
    func testSupplementaryKindsShouldBeSet()
    {
        XCTAssertEqual(controller.manager.memoryStorage.supplementaryHeaderKind, UICollectionView.elementKindSectionHeader)
        XCTAssertEqual(controller.manager.memoryStorage.supplementaryFooterKind, UICollectionView.elementKindSectionFooter)
    }
    
    func testReloadRowsClosure() {
        let exp = expectation(description: "Reload row closure")
        controller.manager.collectionViewUpdater = CollectionViewUpdater(collectionView: controller.collectionView!, reloadItem: { indexPath, model in
            if indexPath.section == 0 && indexPath.item == 3 && (model as? Int) == 4 {
                exp.fulfill()
            }
        })
        
        controller.manager.memoryStorage.addItems([1,2,3,4,5])
        controller.manager.memoryStorage.reloadItem(4)
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    // Anomalies

    func testNilModelInStorageLeadsToNilModelAnomaly() {
        let exp = expectation(description: "Nil model in storage")
        exp.assertForOverFulfill = false
        let model: Int?? = nil
        let anomaly = DTCollectionViewManagerAnomaly.nilCellModel(indexPath(0, 0))
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.memoryStorage.addItem(model)
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTCollectionViewManager] UICollectionView requested a cell at [0, 0], however the model at that indexPath was nil.")
    }
    
    func testNilSupplementaryModelLeadsToAnomaly() {
        let exp = expectation(description: "Nil header model in storage")
        let model: Int?? = nil
        let anomaly = DTCollectionViewManagerAnomaly.nilSupplementaryModel(kind: UICollectionView.elementKindSectionHeader, indexPath: indexPath(0, 0))
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([model])
        let _ = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTCollectionViewManager] UICollectionView requested a supplementary view of kind: UICollectionElementKindSectionHeader at [0, 0], however the model was nil.")
    }
    
    func testNoCellMappingsTriggerAnomaly() {
        let exp = expectation(description: "No cell mappings found for model")
        exp.assertForOverFulfill = false
        let anomaly = DTCollectionViewManagerAnomaly.noCellMappingFound(modelDescription: "3", indexPath: indexPath(0, 0))
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.memoryStorage.addItem("3")
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTCollectionViewManager] UICollectionView requested a cell for model at [0, 0], but view model mapping for it was not found, model description: 3")
    }
    
    func testNoSupplementaryMappingTriggersToAnomaly() {
        let exp = expectation(description: "No supplementary mapping found")
        let anomaly = DTCollectionViewManagerAnomaly.noSupplementaryMappingFound(modelDescription: "0", kind: UICollectionView.elementKindSectionHeader, indexPath: indexPath(0, 0))
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.memoryStorage.setSectionHeaderModels([0])
        controller.manager.memoryStorage.setItems([1])
        let _ = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTCollectionViewManager] UICollectionView requested a supplementary view of kind: UICollectionElementKindSectionHeader for model ar [0, 0], but view model mapping for it was not found, model description: 0")
    }
    
    func testSupplementaryWithDifferentReuseIdentifierTriggersAnomaly() {
        let exp = expectation(description: "Wrong reuse identifier leads to anomaly")
        let anomaly = DTCollectionViewManagerAnomaly.differentSupplementaryReuseIdentifier(mappingReuseIdentifier: "WrongReuseIdentifierReusableView", supplementaryReuseIdentifier: "Bar")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerHeader(WrongReuseIdentifierReusableView.self)
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "❗️[DTCollectionViewManager] Reuse identifier of UICollectionReusableView: Bar does not match reuseIdentifier used to register with UICollectionView: WrongReuseIdentifierReusableView. \n" +
            "If you are using XIB, please remove reuseIdentifier from XIB file, or change it to name of UICollectionReusableView subclass. If you are using Storyboards, please change UICollectionReusableView identifier to name of the class. \n" +
            "If you need different reuseIdentifier for any reason, you can change reuseIdentifier when registering mapping.")
    }
    
    func testWrongCellClassComingFromXibLeadsToAnomaly() {
        let exp = expectation(description: "Wrong cell class")
        let anomaly = DTCollectionViewManagerAnomaly.differentCellClass(xibName: "RandomNibNameCell",
                                                                   cellClass: "NibCell",
                                                                   expectedCellClass: "StringCell")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.register(StringCell.self) { mapping in
            mapping.xibName = "RandomNibNameCell"
        }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTCollectionViewManager] Attempted to register xib RandomNibNameCell, but view found in a xib was of type NibCell, while expected type is StringCell. This can prevent cells from being updated with models and react to events.")
    }
    
    func testEmptyXibCellLeadsToAnomaly() {
        let exp = expectation(description: "Empty xib cell")
        let anomaly = DTCollectionViewManagerAnomaly.emptyXibFile(xibName: "EmptyXib",
                                                             expectedViewClass: "StringCell")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.register(StringCell.self) { mapping in
            mapping.xibName = "EmptyXib"
        }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTCollectionViewManager] Attempted to register xib EmptyXib for StringCell, but this xib does not contain any views.")
    }
    
    func testEmptySupplementaryXibLeadsToAnomaly() {
        let exp = expectation(description: "Empty supplementary xib")
        let anomaly = DTCollectionViewManagerAnomaly.emptyXibFile(xibName: "EmptyXib",
                                                                  expectedViewClass: "NibHeaderFooterView")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerHeader(NibHeaderFooterView.self) { mapping in
            mapping.xibName = "EmptyXib"
        }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTCollectionViewManager] Attempted to register xib EmptyXib for NibHeaderFooterView, but this xib does not contain any views.")
    }
    
    func testWrongHeaderClassComingFromXibLeadsToAnomaly() {
        let exp = expectation(description: "Wrong header class")
        let anomaly = DTCollectionViewManagerAnomaly.differentSupplementaryClass(xibName: "NibView",
                                                                           viewClass: "NibHeaderFooterView",
                                                                           expectedViewClass: "ReactingHeaderFooterView")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.registerHeader(ReactingHeaderFooterView.self) { mapping in
            mapping.xibName = "NibView"
        }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTCollectionViewManager] Attempted to register xib NibView, but view found in a xib was of type NibHeaderFooterView, while expected type is ReactingHeaderFooterView. This can prevent supplementary views from being updated with models and react to events.")
    }
}
