//
//  MappingTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import Nimble
import DTModelStorage
import DTCollectionViewManager

class MappingTestCase: XCTestCase {
    
    var controller = DTCellTestCollectionController()
    
    override func setUp() {
        super.setUp()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.viewBundle = NSBundle(forClass: self.dynamicType)
        controller.manager.storage = MemoryStorage()
    }
    
    func testRegistrationWithDifferentNibName()
    {
        controller.manager.registerNibNamed("RandomNibNameCell", forCellClass: NibCell.self)
        
        controller.manager.memoryStorage.addItem(3)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0,0))) == true
    }
    
    func testOptionalUnwrapping()
    {
        controller.manager.registerCellClass(NibCell)
        
        let intOptional : Int? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testSeveralLevelsOfOptionalUnwrapping()
    {
        controller.manager.registerCellClass(NibCell)
        
        let intOptional : Int?? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testNiblessMapping()
    {
        controller.manager.registerNiblessCellClass(StringCell)
        controller.manager.memoryStorage.addItem("foo")
        
        expect(self.controller.manager.memoryStorage.itemAtIndexPath(indexPath(0, 0)) as? String) == "foo"
    }
    
// MARK: TODO - Reevaluate this functionality in the future
// Is there a reason to have optional cell mapping or not?
//    func testOptionalModelCellMapping()
//    {
//        controller.registerCellClass(OptionalIntCell)
//
//        controller.memoryStorage.addItem(Optional(1), toSection: 0)
//
//        expect(self.controller.verifyItem(1, atIndexPath: indexPath(0, 0))) == true
//    }
    
    
//    func testHeaderMappingFromHeaderFooterView()
//    {
//        controller.manager.registerHeaderClass(NibHeaderFooterView)
//        controller.manager.registerCellClass(NibCell)
//
//        let section = SectionModel()
//        section.collectionHeaderModel = 1
//        controller.manager.memoryStorage.setSection(section, forSectionIndex: 0)
//        let view = controller.manager.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, atIndexPath:  indexPath(0, 0))
//        expect(view).to(beAKindOf(NibHeaderFooterView.self))
//    }
//
//    func testFooterViewMappingFromUIView()
//    {
//        controller.manager.registerFooterClass(NibView)
//        
//        controller.manager.memoryStorage.setSectionFooterModels([1])
//        let view = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0)
//        expect(view).to(beAKindOf(NibView.self))
//    }
//    
//    func testFooterMappingFromHeaderFooterView()
//    {
//        controller.manager.registerHeaderClass(ReactingHeaderFooterView)
//        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
//        let view = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0)
//        expect(view).to(beAKindOf(ReactingHeaderFooterView.self))
//    }
//    
//    func testHeaderViewShouldSupportNSStringModel()
//    {
//        controller.manager.registerNibNamed("NibHeaderFooterView", forHeaderType: NibHeaderFooterView.self)
//        controller.manager.memoryStorage.setSectionHeaderModels([1])
//        expect(self.controller.manager.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beAKindOf(NibHeaderFooterView))
//    }
//
}
