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
@testable import DTCollectionViewManager

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
        controller.manager.startManaging(withDelegate: controller)
        controller.manager.storage = MemoryStorage()
    }
    
    func testCellSelectionClosure()
    {
        controller.manager.register(SelectionReactingCollectionCell.self)
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
        controller.manager.register(SelectionReactingCollectionCell.self)
        
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
        sut.manager.startManaging(withDelegate: sut)
        sut.manager.storage = MemoryStorage()
        sut.manager.register(NibCell.self)
        sut.manager.registerHeader(NibHeaderFooterView.self)
        sut.manager.registerFooter(NibHeaderFooterView.self)
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
    
    func testShouldSelectItemAtIndexPath() {
        let exp = expectation(description: "shouldSelectItemAtIndexPath")
        sut.manager.shouldSelect(NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionView(sut.collectionView!, shouldSelectItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldDeselectItemAtIndexPath() {
        let exp = expectation(description: "shouldDeselectItemAtIndexPath")
        sut.manager.shouldDeselect(NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionView(sut.collectionView!, shouldDeselectItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidDeselectItemAtIndexPath() {
        let exp = expectation(description: "didDeselectItemAtIndexPath")
        sut.manager.didDeselect(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionView(sut.collectionView!, didDeselectItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldHighlightItemAtIndexPath() {
        let exp = expectation(description: "shouldHighlightItemAtIndexPath")
        sut.manager.shouldHighlight(NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionView(sut.collectionView!, shouldHighlightItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidHighlightItemAtIndexPath() {
        let exp = expectation(description: "didHighlightItemAtIndexPath")
        sut.manager.didHighlight(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionView(sut.collectionView!, didHighlightItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidUnhighlightItemAtIndexPath() {
        let exp = expectation(description: "didUnhighlightItemAtIndexPath")
        sut.manager.didUnhighlight(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionView(sut.collectionView!, didUnhighlightItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayItemAtIndexPath() {
        let exp = expectation(description: "willDisplayItemAtIndexPath")
        sut.manager.willDisplay(NibCell.self, { cell, model, indexPath  in
            // Method is called twice due to complex storage updating logic, so we are waiting 0.1 second and cancel all previous requests
            type(of: exp).cancelPreviousPerformRequests(withTarget: exp)
            exp.perform(#selector(XCTestExpectation.fulfill), with: nil, afterDelay: 0.1)
            return
        })
        sut.manager.memoryStorage.addItem(3)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplaySupplementaryViewAtIndexPath() {
        let exp = expectation(description: "willDisplaySupplementaryViewAtIndexPath")
        sut.manager.willDisplaySupplementaryView(NibHeaderFooterView.self, forElementKind: UICollectionElementKindSectionHeader, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionView(sut.collectionView!, willDisplaySupplementaryView: NibHeaderFooterView(), forElementKind:UICollectionElementKindSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayHeaderViewAtIndexPath() {
        let exp = expectation(description: "willDisplayHeaderViewAtIndexPath")
        sut.manager.willDisplayHeaderView(NibHeaderFooterView.self, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionView(sut.collectionView!, willDisplaySupplementaryView: NibHeaderFooterView(), forElementKind:UICollectionElementKindSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayFooterViewAtIndexPath() {
        let exp = expectation(description: "willDisplayHeaderViewAtIndexPath")
        sut.manager.willDisplayFooterView(NibHeaderFooterView.self, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionFooterModels([5])
        _ = sut.manager.collectionView(sut.collectionView!, willDisplaySupplementaryView: NibHeaderFooterView(), forElementKind:UICollectionElementKindSectionFooter, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEndDisplayingItemAtIndexPath() {
        let exp = expectation(description: "didEndDisplayingItemAtIndexPath")
        sut.manager.didEndDisplaying(NibCell.self, { cell, model, indexPath  in
            // Method is called twice due to complex storage updating logic, so we are waiting 0.1 second and cancel all previous requests
            type(of: exp).cancelPreviousPerformRequests(withTarget: exp)
            exp.perform(#selector(XCTestExpectation.fulfill), with: nil, afterDelay: 0.1)
            return
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionView(sut.collectionView!, didEndDisplaying: NibCell(), forItemAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingSupplementaryViewAtIndexPath() {
        let exp = expectation(description: "didEndDisplayingSupplementaryViewAtIndexPath")
        sut.manager.didEndDisplayingSupplementaryView(NibHeaderFooterView.self, forElementKind: UICollectionElementKindSectionHeader, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionView(sut.collectionView!, didEndDisplayingSupplementaryView: NibHeaderFooterView(), forElementOfKind:UICollectionElementKindSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingHeaderViewAtIndexPath() {
        let exp = expectation(description: "didEndDisplayingHeaderViewAtIndexPath")
        sut.manager.didEndDisplayingHeaderView(NibHeaderFooterView.self, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionView(sut.collectionView!, didEndDisplayingSupplementaryView: NibHeaderFooterView(), forElementOfKind:UICollectionElementKindSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEndDisplayingFooterViewAtIndexPath() {
        let exp = expectation(description: "didEndDisplayingHeaderViewAtIndexPath")
        sut.manager.didEndDisplayingFooterView(NibHeaderFooterView.self, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionFooterModels([5])
        _ = sut.manager.collectionView(sut.collectionView!, didEndDisplayingSupplementaryView: NibHeaderFooterView(), forElementOfKind:UICollectionElementKindSectionFooter, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldShowMenuForItemAtIndexPath() {
        let exp = expectation(description: "shouldshowMenuForItemAtIndexPath")
        sut.manager.shouldShowMenu(for: NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionView(sut.collectionView!, shouldShowMenuForItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "canPerformActionForRowAtIndexPath")
        sut.manager.canPerformAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionView(sut.collectionView!, canPerformAction: #selector(testShouldShowMenuForItemAtIndexPath), forItemAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "performActionForItemAtIndexPath")
        sut.manager.performAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionView(sut.collectionView!, performAction: #selector(testShouldShowMenuForItemAtIndexPath), forItemAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    func testCanFocusItemAtIndexPath() {
        let exp = expectation(description: "canFocusRowAtIndexPath")
        sut.manager.canFocus(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionView(sut.collectionView!, canFocusItemAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSizeForItemAtIndexPath() {
        let exp = expectation(description: "sizeForItemAtIndexPath")
        sut.manager.sizeOfCell(withItem: Int.self, { (model, indexPath) -> CGSize in
            exp.fulfill()
            return .zero
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionView(sut.collectionView!, layout: UICollectionViewFlowLayout(), sizeForItemAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSizeForHeaderInSection() {
        let exp = expectation(description: "sizeForHeaderInSection")
        sut.manager.referenceSizeForHeaderView(withItem: Int.self, { (model, indexPath) -> CGSize in
            exp.fulfill()
            return .zero
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionView(sut.collectionView!, layout: UICollectionViewFlowLayout(), referenceSizeForHeaderInSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSizeForFooterInSection() {
        let exp = expectation(description: "sizeForFooterInSection")
        sut.manager.referenceSizeForFooterView(withItem: Int.self, { (model, indexPath) -> CGSize in
            exp.fulfill()
            return .zero
        })
        sut.manager.memoryStorage.setSectionFooterModels([5])
        _ = sut.manager.collectionView(sut.collectionView!, layout: UICollectionViewFlowLayout(), referenceSizeForFooterInSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAllDelegateMethodSignatures() {
        if #available(iOS 9, tvOS 9, *) {
            expect(String(describing: #selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:)))) == EventMethodSignature.canMoveItemAtIndexPath.rawValue
        }
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:)))) == EventMethodSignature.shouldSelectItemAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)))) == EventMethodSignature.didSelectItemAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:)))) == EventMethodSignature.shouldDeselectItemAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)))) == EventMethodSignature.didDeselectItemAtIndexPath.rawValue
        
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)))) == EventMethodSignature.shouldHighlightItemAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)))) == EventMethodSignature.didHighlightItemAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)))) == EventMethodSignature.didUnhighlightItemAtIndexPath.rawValue
        
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)))) == EventMethodSignature.willDisplayCellForItemAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)))) == EventMethodSignature.willDisplaySupplementaryViewForElementKindAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)))) == EventMethodSignature.didEndDisplayingCellForItemAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)))) == EventMethodSignature.didEndDisplayingSupplementaryViewForElementKindAtIndexPath.rawValue
        
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:)))) == EventMethodSignature.shouldShowMenuForItemAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:)))) == EventMethodSignature.canPerformActionForItemAtIndexPath.rawValue
        expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:)))) == EventMethodSignature.performActionForItemAtIndexPath.rawValue
        
        if #available(iOS 9, tvOS 9, *) {
            expect(String(describing: #selector(UICollectionViewDelegate.collectionView(_:canFocusItemAt:)))) == EventMethodSignature.canFocusItemAtIndexPath.rawValue
        }
        
        expect(String(describing: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)))) == EventMethodSignature.sizeForItemAtIndexPath.rawValue
        
        // These methods are not equal on purpose - DTCollectionViewManager implements custom logic in them, and they are always implemented, even though they can act as events
        expect(String(describing: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:)))) != EventMethodSignature.referenceSizeForHeaderInSection.rawValue
        expect(String(describing: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:)))) != EventMethodSignature.referenceSizeForFooterInSection.rawValue
    }
    
    func testEventRegistrationPerfomance() {
        let manager = sut.manager
        
        measure {
            manager.shouldSelect(NibCell.self, { _ in return true })
            manager.didSelect(NibCell.self, { _ in })
            manager.shouldDeselect(NibCell.self, { _ in return true })
            manager.didDeselect(NibCell.self, { _ in })
            manager.shouldHighlight(NibCell.self, { _ in return true })
            manager.didHighlight(NibCell.self, { _ in })
            manager.didUnhighlight(NibCell.self, { _ in })
            manager.willDisplay(NibCell.self, { _ in})
            manager.willDisplayHeaderView(NibHeaderFooterView.self, { _ in })
            manager.willDisplayFooterView(NibHeaderFooterView.self, { _ in })
            manager.willDisplaySupplementaryView(NibHeaderFooterView.self, forElementKind: "foo", {_ in })
            manager.didEndDisplaying(NibCell.self, { _ in })
            manager.didEndDisplayingHeaderView(NibHeaderFooterView.self, { _ in })
            manager.didEndDisplayingFooterView(NibHeaderFooterView.self, { _ in })
            manager.didEndDisplayingSupplementaryView(NibHeaderFooterView.self, forElementKind: "foo", { _ in })
            manager.shouldShowMenu(for: NibCell.self, { _ in return true })
            manager.canPerformAction(for: NibCell.self, { _ in return true })
            manager.performAction(for: NibCell.self, { _ in })
            manager.sizeOfCell(withItem: Int.self, { _ in return .zero })
            manager.referenceSizeForHeaderView(withItem: Int.self, { _ in return .zero })
            manager.referenceSizeForFooterView(withItem: Int.self, { _ in return .zero })
        }
    }
}
