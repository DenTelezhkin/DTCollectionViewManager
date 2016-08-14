//
//  ReactingToEventsTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import Nimble
import DTCollectionViewManager

class ReactingTestCollectionViewController: DTCellTestCollectionController
{
    var indexPath : IndexPath?
    var model: Int?
    var text : String?
    
    func cellConfiguration(_ cell: SelectionReactingCollectionCell, model: Int, indexPath: IndexPath) {
        cell.indexPath = indexPath
        cell.model = model
        cell.textLabel?.text = "Foo"
    }
    
    func headerConfiguration(_ header: ReactingHeaderFooterView, model: String, sectionIndex: Int) {
        header.model = "Bar"
        header.sectionIndex = sectionIndex
    }
    
    func cellSelection(_ cell: SelectionReactingCollectionCell, model: Int, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.model = model
        self.text = "Bar"
    }
}

class ReactingToEventsTestCase: XCTestCase {
    
    var controller : ReactingTestCollectionViewController!
    
    override func setUp() {
        super.setUp()
        controller = ReactingTestCollectionViewController()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.storage = MemoryStorage()
    }
    
    func testCellSelectionClosure()
    {
        controller.manager.registerCellClass(SelectionReactingCollectionCell.self)
        var reactingCell : SelectionReactingCollectionCell?
        controller.manager.didSelect(SelectionReactingCollectionCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.collectionView(controller.collectionView!, didSelectItemAt: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
    
    func testCellConfigurationClosure()
    {
        controller.manager.registerCellClass(SelectionReactingCollectionCell.self)
        
        var reactingCell : SelectionReactingCollectionCell?
        
        controller.manager.configureCell(SelectionReactingCollectionCell.self, { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            cell.textLabel?.text = "Foo"
            reactingCell = cell
        })
        
        controller.manager.memoryStorage.addItem(2, toSection: 0)
        _ = controller.manager.collectionView(controller.collectionView!, cellForItemAt: indexPath(0, 0))
        
        expect(reactingCell?.indexPath) == indexPath(0, 0)
        expect(reactingCell?.model) == 2
        expect(reactingCell?.textLabel?.text) == "Foo"
    }
    
//    func testHeaderConfigurationClosure()
//    {
//        controller.manager.registerHeaderClass(ReactingHeaderFooterView)
//        
//        var reactingHeader : ReactingHeaderFooterView?
//        
//        controller.manager.configureHeader(ReactingHeaderFooterView.self) { (header, model, sectionIndex) in
//            header.model = "Bar"
//            header.sectionIndex = sectionIndex
//        }
//        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
//        reactingHeader = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0) as? ReactingHeaderFooterView
//        
//        expect(reactingHeader?.sectionIndex) == 0
//        expect(reactingHeader?.model) == "Bar"
//    }
//    
//    func testFooterConfigurationClosure()
//    {
//        controller.manager.registerFooterClass(ReactingHeaderFooterView)
//        
//        var reactingFooter : ReactingHeaderFooterView?
//        
//        controller.manager.configureFooter(ReactingHeaderFooterView.self) { (footer, model, sectionIndex) in
//            footer.model = "Bar"
//            footer.sectionIndex = sectionIndex
//        }
//        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
//        reactingFooter = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0) as? ReactingHeaderFooterView
//        
//        expect(reactingFooter?.sectionIndex) == 0
//        expect(reactingFooter?.model) == "Bar"
//    }
    
    
}

class ReactingToEventsFastTestCase : XCTestCase {
    var sut : DTCellTestCollectionController!
    
    override func setUp() {
        super.setUp()
        sut = DTCellTestCollectionController()
        let _ = sut.view
        sut.manager.startManagingWithDelegate(sut)
        sut.manager.storage = MemoryStorage()
        sut.manager.registerCellClass(NibCell.self)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    func testCanMoveItemAtIndexPath() {
        let exp = expectation(description: "canMoveItemAtIndexPath")
        sut.manager.canMove(NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionView(sut.collectionView!, canMoveItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
}
