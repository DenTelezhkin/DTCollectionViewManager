//
//  DataSourceTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import DTCollectionViewManager
import Nimble

class DataSourceTestCase: XCTestCase {
    
    var controller = DTCellTestCollectionController()
    
    override func setUp() {
        super.setUp()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.viewBundle = NSBundle(forClass: self.dynamicType)
        controller.manager.storage = MemoryStorage()
        
        controller.manager.registerCellClass(NibCell)
    }
    
    func testCollectionItemAtIndexPath()
    {
        controller.manager.memoryStorage.addItem(3)
        controller.manager.memoryStorage.addItems([2,1,6,4], toSection: 0)
        
        expect(self.controller.verifyItem(6, atIndexPath: indexPath(3, 0))) == true
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
        expect(self.controller.manager.memoryStorage.itemAtIndexPath(indexPath(56, 0))).to(beNil())
    }
    
    func testShouldReturnCorrectNumberOfCollectionItems()
    {
        controller.manager.memoryStorage.addItems([1,1,1,1], toSection: 0)
        controller.manager.memoryStorage.addItems([2,2,2], toSection: 1)
        let collectionView = controller.collectionView
        expect(self.controller.manager.collectionView(collectionView!, numberOfItemsInSection: 0)) == 4
        expect(self.controller.manager.collectionView(collectionView!, numberOfItemsInSection: 1)) == 3
    }
    
    func testShouldReturnCorrectNumberOfSections()
    {
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        controller.manager.memoryStorage.addItem(4, toSection: 3)
        controller.manager.memoryStorage.addItem(2, toSection: 2)
        
        expect(self.controller.manager.numberOfSectionsInCollectionView(self.controller.collectionView!)) == 4
    }
    
    func testShouldAddTableItems()
    {
        controller.manager.memoryStorage.addItems([3,2], toSection: 0)
        
        expect(self.controller.manager.memoryStorage.itemsInSection(0)?.count) == 2
    }
    
    func testShouldInsertTableItem()
    {
        controller.manager.memoryStorage.addItems([2,4,6], toSection: 0)
        try! controller.manager.memoryStorage.insertItem(1, toIndexPath: indexPath(2, 0))
        
        expect(self.controller.manager.memoryStorage.itemsInSection(0)?.count) == 4
        expect(self.controller.verifyItem(1, atIndexPath: indexPath(2, 0))) == true
        expect(self.controller.verifyItem(6, atIndexPath: indexPath(3, 0))) == true
    }
    
    func testReplaceItem()
    {
        controller.manager.memoryStorage.addItems([1,3], toSection: 0)
        controller.manager.memoryStorage.addItems([4,6], toSection: 1)
        try! controller.manager.memoryStorage.replaceItem(3, replacingItem: 2)
        try! controller.manager.memoryStorage.replaceItem(4, replacingItem: 5)
        
        expect(self.controller.manager.memoryStorage.itemsInSection(0)?.count) == 2
        expect(self.controller.manager.memoryStorage.itemsInSection(1)?.count) == 2
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(1, 0))) == true
        expect(self.controller.verifyItem(5, atIndexPath: indexPath(0, 1))) == true
    }
    
    func testRemoveItem()
    {
        controller.manager.memoryStorage.addItems([1,3,2,4], toSection: 0)
        controller.manager.memoryStorage.removeItems([1,4,3,5])
        
        expect(self.controller.manager.memoryStorage.itemsInSection(0)?.count) == 1
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testRemoveItems()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.setItems([Int](), forSectionIndex: 0)
        
        expect(self.controller.manager.memoryStorage.itemsInSection(0)?.count) == 0
    }
    
    func testMovingItems()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.moveItemAtIndexPath(indexPath(0, 0), toIndexPath: indexPath(2, 0))
        
        expect(self.controller.verifySection([2,3,1], withSectionNumber: 0)) == true
    }
    
    func testShouldNotCrashWhenMovingToBadRow()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        
        controller.manager.memoryStorage.moveItemAtIndexPath(indexPath(0, 0), toIndexPath: indexPath(2, 1))
    }
    
    func testShouldNotCrashWhenMovingFromBadRow()
    {
        controller.manager.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.manager.memoryStorage.moveItemAtIndexPath(indexPath(0, 1), toIndexPath: indexPath(0, 0))
    }
    
    func testShouldMoveSections()
    {
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        controller.manager.memoryStorage.addItem(3, toSection: 2)
        
        controller.manager.memoryStorage.moveSection(0, toSection: 1)
        
        expect(self.controller.verifySection([2], withSectionNumber: 0)) == true
        expect(self.controller.verifySection([1], withSectionNumber: 1)) == true
        expect(self.controller.verifySection([3], withSectionNumber: 2)) == true
    }
    
    func testShouldDeleteSections()
    {
        controller.manager.memoryStorage.addItem(0, toSection: 0)
        controller.manager.memoryStorage.addItem(1, toSection: 1)
        controller.manager.memoryStorage.addItem(2, toSection: 2)
        
        controller.manager.memoryStorage.deleteSections(NSIndexSet(index: 1))
        
        expect(self.controller.manager.memoryStorage.sections.count) == 2
        expect(self.controller.verifySection([2], withSectionNumber: 1))
    }
    
    
    func testSupplementaryKindsShouldBeSet()
    {
        expect(self.controller.manager.memoryStorage.supplementaryHeaderKind) == UICollectionElementKindSectionHeader
        expect(self.controller.manager.memoryStorage.supplementaryFooterKind) == UICollectionElementKindSectionFooter
    }

    // TODO: Figure out way to test supplementaries
    
//    func testHeaderViewShouldBeCreated()
//    {
//        controller.manager.registerCellClass(NibCell)
//        controller.manager.registerHeaderClass(NibHeaderFooterView)
//        controller.manager.memoryStorage.updateWithoutAnimations {
//            self.controller.manager.memoryStorage.setSupplementaries([1], forKind: UICollectionElementKindSectionHeader)
//        }
//    
//        controller.collectionView?.reloadData()
//        controller.collectionView?.performBatchUpdates(nil, completion: nil)
//        
//        expect(self.controller.manager.collectionView(self.controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, atIndexPath: indexPath(0, 0))).to(beAKindOf(NibHeaderFooterView))
//    }
    
//    func testFooterViewShouldBeCreated()
//    {
//        controller.manager.registerFooterClass(NibHeaderFooterView)
//        let section = SectionModel()
//        section.collectionFooterModel = 1
//        section.setItems([3,4])
//        controller.manager.memoryStorage.setSection(section, forSectionIndex: 0)
//        if #available(iOS 9.0, *) {
//            expect(self.controller.collectionView?.supplementaryViewForElementKind(UICollectionElementKindSectionFooter, atIndexPath: indexPath(0, 0))).to(beAKindOf(NibHeaderFooterView))
//        } else {
//            // Fallback on earlier versions
//        }
//        expect(self.controller.manager.collectionView(self.controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionFooter, atIndexPath: indexPath(0, 0))).to(beAKindOf(NibHeaderFooterView))
//    }
    
    func testObjectForCellAtIndexPathGenericConversion()
    {
        controller.manager.registerCellClass(NibCell)
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        if let object = controller.manager.storage.itemForCellClass(NibCell.self, atIndexPath: indexPath(0, 0))
        {
            expect(object) == 1
        }
        else {
            XCTFail("")
        }
    }
    
    func testObjectForCell() {
        controller.manager.registerCellClass(NibCell)
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        if let object = controller.manager.itemForCellClass(NibCell.self, atIndexPath: indexPath(0, 0))
        {
            expect(object) == 1
        }
        else {
            XCTFail("")
        }
    }
    
    func testObjectAtIndexPathGenericConversionFailsForNil()
    {
        controller.manager.registerCellClass(NibCell)
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        if let _ = controller.manager.storage.itemForCellClass(StringCell.self, atIndexPath: indexPath(0, 0))
        {
            XCTFail()
        }
    }
    
    func testCollectionHeaderProperty() {
        let section = SectionModel()
        section.collectionHeaderModel = 1
        
        expect(section.supplementaryModelOfKind(UICollectionElementKindSectionHeader) as? Int) == 1
        expect(section.collectionHeaderModel as? Int) == 1
    }
    
    func testCollectionFooterProperty() {
        let section = SectionModel()
        section.collectionFooterModel = 1
        
        expect(section.supplementaryModelOfKind(UICollectionElementKindSectionFooter) as? Int) == 1
        expect(section.collectionFooterModel as? Int) == 1
    }
    
    func testHeaderObjectForViewGenericConversion()
    {
        controller.manager.registerHeaderClass(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        if let _ = controller.manager.itemForHeaderClass(NibHeaderFooterView.self, atSectionIndex: 0)
        {
            
        }
        else {
            XCTFail()
        }
    }
    
    func testFooterObjectForViewGenericConversion()
    {
        controller.manager.registerFooterClass(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        if let _ = controller.manager.itemForFooterClass(NibHeaderFooterView.self, atSectionIndex: 0)
        {
            
        }
        else {
            XCTFail()
        }
    }
    
    func testSupplementaryObjectForViewGenericConversion()
    {
        controller.manager.registerFooterClass(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        if let _ = controller.manager.itemForSupplementaryClass(NibHeaderFooterView.self, ofKind: UICollectionElementKindSectionFooter, atSectionIndex: 0)
        {
            
        }
        else {
            XCTFail()
        }
    }
//
//    func testFooterObjectForViewGenericConversion()
//    {
//        controller.manager.registerNibNamed("NibHeaderFooterView", forFooterType: NibHeaderFooterView.self)
//        controller.manager.memoryStorage.setSectionFooterModels([1])
//        let header = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0)
//        if let _ = controller.manager.storage.objectForTableFooter(header as? NibHeaderFooterView, atSectionIndex: 0)
//        {
//            
//        }
//        else {
//            XCTFail()
//        }
//    }
}
