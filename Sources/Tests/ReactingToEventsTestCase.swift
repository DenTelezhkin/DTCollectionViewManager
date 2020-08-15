//
//  ReactingToEventsTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTCollectionViewManager
#if canImport(TVUIKit)
import TVUIKit
#endif
#if os(iOS)
    
class SpringLoadedContextMock : NSObject, UISpringLoadedInteractionContext {
    var state: UISpringLoadedInteractionEffectState = .activated
    
    var targetView: UIView?
    var targetItem: Any?
    func location(in view: UIView?) -> CGPoint {
        return .zero
    }
}

class DragAndDropMock : NSObject, UIDragSession, UIDropSession {
    var progress: Progress = Progress()
    
    var localDragSession: UIDragSession?
    
    var progressIndicatorStyle: UIDropSessionProgressIndicatorStyle = .default
    
    func canLoadObjects(ofClass aClass: NSItemProviderReading.Type) -> Bool {
        return false
    }
    
    func loadObjects(ofClass aClass: NSItemProviderReading.Type, completion: @escaping ([NSItemProviderReading]) -> Void) -> Progress {
        return Progress()
    }
    
    var items: [UIDragItem] = []
    
    func location(in view: UIView) -> CGPoint {
        return CGPoint()
    }
    
    var allowsMoveOperation: Bool = true
    
    var isRestrictedToDraggingApplication: Bool = false
    
    func hasItemsConforming(toTypeIdentifiers typeIdentifiers: [String]) -> Bool {
        return false
    }
    
    var localContext: Any?
}

class DropPlaceholderContextMock : NSObject, UICollectionViewDropPlaceholderContext {
    func setNeedsCellUpdate() {
        
    }
    
    var dragItem: UIDragItem = UIDragItem(itemProvider: NSItemProvider(contentsOf: URL(fileURLWithPath: ""))!)
    func commitInsertion(dataSourceUpdates: (IndexPath) -> Void) -> Bool {
        return true
    }
    
    func deletePlaceholder() -> Bool {
        return true
    }
    
    func addAnimations(_ animations: @escaping () -> Void) {
        
    }
    
    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        
    }
}
    
class DropCoordinatorMock: NSObject, UICollectionViewDropCoordinator{
    var items: [UICollectionViewDropItem] = []
    
    var destinationIndexPath: IndexPath?
    var proposal: UICollectionViewDropProposal = .init(operation: .copy, intent: .insertAtDestinationIndexPath)
    
    var session: UIDropSession = DragAndDropMock()
    
    override init() {
        super.init()
    }
    
    func drop(_ dragItem: UIDragItem, toItemAt indexPath: IndexPath) -> UIDragAnimating {
        return DropPlaceholderContextMock()
    }
    
    func drop(_ dragItem: UIDragItem, to placeholder: UICollectionViewDropPlaceholder) -> UICollectionViewDropPlaceholderContext {
        return DropPlaceholderContextMock()
    }
    
    func drop(_ dragItem: UIDragItem, intoItemAt indexPath: IndexPath, rect: CGRect) -> UIDragAnimating {
        return DropPlaceholderContextMock()
    }
    
    func drop(_ dragItem: UIDragItem, to target: UIDragPreviewTarget) -> UIDragAnimating {
        return DropPlaceholderContextMock()
    }
}

@available(iOS 13, *)
class ContextMenuInteractionAnimatorMock: NSObject, UIContextMenuInteractionCommitAnimating {
    var preferredCommitStyle: UIContextMenuInteractionCommitStyle = .pop
    
    var previewViewController: UIViewController?
    
    func addAnimations(_ animations: @escaping () -> Void) {
        
    }
    
    func addCompletion(_ completion: @escaping () -> Void) {
        
    }
    
    
}

    
#endif

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
        controller.manager.collectionDelegate?.collectionView(controller.collectionView!, didSelectItemAt: indexPath(1, 0))
        
        XCTAssertEqual(reactingCell?.indexPath, indexPath(1, 0))
        XCTAssertEqual(reactingCell?.model, 2)
    }
    
    func testCellConfigurationClosure()
    {
        var reactingCell : SelectionReactingCollectionCell?
        controller.manager.register(SelectionReactingCollectionCell.self, handler: { cell, model, indexPath in
            cell.indexPath = indexPath
            cell.model = model
            cell.textLabel?.text = "Foo"
            reactingCell = cell
        })
        
        controller.manager.memoryStorage.addItem(2, toSection: 0)
        _ = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0, 0))
        
        XCTAssertEqual(reactingCell?.indexPath, indexPath(0, 0))
        XCTAssertEqual(reactingCell?.model, 2)
        XCTAssertEqual(reactingCell?.textLabel?.text, "Foo")
    }
    
    func testUnregisteredMappingCausesAnomalyWhenEventIsRegistered() {
        let exp = expectation(description: "No mappings found")
        let anomaly = DTCollectionViewManagerAnomaly.eventRegistrationForUnregisteredMapping(viewClass: "SelectionReactingCollectionCell", signature: EventMethodSignature.didSelectItemAtIndexPath.rawValue)
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.didSelect(SelectionReactingCollectionCell.self) { _, _, _ in
            
        }
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTCollectionViewManager] While registering event reaction for collectionView:didSelectItemAtIndexPath:, no view mapping was found for view: SelectionReactingCollectionCell")
    }
}

class ReactingToEventsFastTestCase : XCTestCase {
    var sut : DTCellTestCollectionController!
    
    override func setUp() {
        super.setUp()
        sut = DTCellTestCollectionController()
        let _ = sut.view
        sut.manager.register(NibCell.self)
        sut.manager.registerHeader(NibHeaderFooterView.self)
        sut.manager.registerFooter(NibHeaderFooterView.self)
    }
    
    func unregisterAll() {
        sut.manager.viewFactory.mappings.removeAll()
    }
    
    func fullfill<Cell,Model,ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (Cell,Model,IndexPath) -> ReturnValue {
        { cell, model, indexPath in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func fullfill<Cell,Model,Argument,ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (Argument,Cell,Model,IndexPath) -> ReturnValue {
        { argument,cell, model, indexPath in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func fullfill<Cell,Model,ArgumentOne,ArgumentTwo,ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (ArgumentOne,ArgumentTwo,Cell,Model,IndexPath) -> ReturnValue {
        { argumentOne, argumentTwo, cell, model, indexPath in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func fullfill<Model, ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (Model,IndexPath) -> ReturnValue {
        { model, indexPath in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func addIntItem(_ item: Int = 3) -> (DTCellTestCollectionController) -> Void {
        {
            $0.manager.memoryStorage.addItem(item)
        }
    }
    
    func setHeaderIntModels(_ models: [Int] = [5]) -> (DTCellTestCollectionController) -> Void {
        {
            $0.manager.memoryStorage.setSectionHeaderModels(models)
        }
    }
    
    func setFooterIntModels(_ models: [Int] = [5]) -> (DTCellTestCollectionController) -> Void {
        {
            $0.manager.memoryStorage.setSectionFooterModels(models)
        }
    }
    
    func verifyEvent<U: Equatable>(_ signature: EventMethodSignature,
                                                   registration: (DTCellTestCollectionController, XCTestExpectation) -> Void,
                                                   alternativeRegistration: (DTCellTestCollectionController, XCTestExpectation) -> Void,
                                                   preparation: (DTCellTestCollectionController) -> Void,
                                                   action: (DTCellTestCollectionController) throws -> U,
                                                   expectedResult: U? = nil) throws {
        guard let sut = sut else {
            XCTFail()
            return
        }
        unregisterAll()
        
        let exp = expectation(description: signature.rawValue)
        registration(sut,exp)
        preparation(sut)
        let result = try action(sut)
        if let expectedResult = expectedResult {
            XCTAssertEqual(result, expectedResult)
        }
        waitForExpectations(timeout: 1)
        
        unregisterAll()
        
        let altExp = expectation(description: signature.rawValue)
        alternativeRegistration(sut,altExp)
        preparation(sut)
        let altResult = try action(sut)
        if let expectedResult = expectedResult {
            XCTAssertEqual(altResult, expectedResult)
        }
        waitForExpectations(timeout: 1)
    }
    
    func verifyEvent<U>(_ signature: EventMethodSignature,
                                                   registration: (DTCellTestCollectionController, XCTestExpectation) -> Void,
                                                   alternativeRegistration: (DTCellTestCollectionController, XCTestExpectation) -> Void,
                                                   preparation: (DTCellTestCollectionController) -> Void,
                                                   action: (DTCellTestCollectionController) throws -> U) throws {
        guard let sut = sut else {
            XCTFail()
            return
        }
        unregisterAll()
        
        let exp = expectation(description: signature.rawValue)
        registration(sut,exp)
        preparation(sut)
        _ = try action(sut)
        waitForExpectations(timeout: 1)
        
        unregisterAll()
        
        let altExp = expectation(description: signature.rawValue)
        alternativeRegistration(sut,altExp)
        preparation(sut)
        _ = try action(sut)
        waitForExpectations(timeout: 1)
    }
    
    @available(tvOS 9.0, *)
    func testCanMoveItemAtIndexPath() throws {
        try verifyEvent(.canMoveItemAtIndexPath, registration: { sut, exp in
            sut.manager.register(NibCell.self)
            sut.manager.canMove(NibCell.self, fullfill(exp, andReturn: true))
        }, alternativeRegistration: { sut, exp in
            sut.manager.register(NibCell.self) { mapping in
                mapping.canMove(self.fullfill(exp, andReturn: true))
            }
        }, preparation: addIntItem(),
        action: { sut in
            sut.manager.collectionDataSource?.collectionView(sut.collectionView, canMoveItemAt: indexPath(0,0)) ?? false
        },
        expectedResult: true)
    }
    
    func testCellSelectionClosure() throws {
        try verifyEvent(.didSelectItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didSelect(NibCell.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didSelect(self.fullfill(exp, andReturn: ()))}
        }, preparation: addIntItem(), action: {
            $0.manager.collectionDelegate?.collectionView(sut.collectionView, didSelectItemAt: indexPath(0, 0))
        })
    }
    
    func testShouldSelectItemAtIndexPath() throws {
        try verifyEvent(.shouldSelectItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.shouldSelect(NibCell.self, fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.shouldSelect(self.fullfill(exp, andReturn: true))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, shouldSelectItemAt: indexPath(0, 0)))
        }, expectedResult: true)
    }
    
    func testShouldDeselectItemAtIndexPath() throws {
        try verifyEvent(.shouldDeselectItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.shouldDeselect(NibCell.self, fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.shouldDeselect(self.fullfill(exp, andReturn: true)) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, shouldDeselectItemAt: indexPath(0, 0)))
        }, expectedResult: true)
    }
    
    func testDidDeselectItemAtIndexPath() throws {
        try verifyEvent(.didDeselectItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didDeselect(NibCell.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didDeselect(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.collectionDelegate?.collectionView(sut.collectionView, didDeselectItemAt: indexPath(0, 0))
        })
    }
    
    func testShouldHighlightItemAtIndexPath() throws {
        try verifyEvent(.shouldHighlightItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.shouldHighlight(NibCell.self, fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.shouldHighlight(self.fullfill(exp, andReturn: true))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, shouldHighlightItemAt: indexPath(0, 0)))
        }, expectedResult: true)
    }
    
    func testDidHighlightItemAtIndexPath() throws {
        try verifyEvent(.didHighlightItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didHighlight(NibCell.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didHighlight(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, didHighlightItemAt: indexPath(0,0)))
        })
    }
    
    func testDidUnhighlightItemAtIndexPath() throws {
        try verifyEvent(.didUnhighlightItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didUnhighlight(NibCell.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didUnhighlight(self.fullfill(exp, andReturn: ()))}
        }, preparation: addIntItem(), action: {
            $0.manager.collectionDelegate?.collectionView(sut.collectionView, didUnhighlightItemAt: indexPath(0, 0))
        })
    }
    
    func testWillDisplayItemAtIndexPath() throws {
        try verifyEvent(.willDisplayCellForItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.willDisplay(NibCell.self) { _, _, _ in
                type(of: exp).cancelPreviousPerformRequests(withTarget: exp)
                exp.perform(#selector(XCTestExpectation.fulfill), with: nil, afterDelay: 0.1)
                return
            }
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.willDisplay { _, _, _ in
                type(of: exp).cancelPreviousPerformRequests(withTarget: exp)
                exp.perform(#selector(XCTestExpectation.fulfill), with: nil, afterDelay: 0.1)
                return
            }}
        }, preparation: addIntItem(), action: { _ in })
    }
    
    func testWillDisplaySupplementaryViewAtIndexPath() throws {
        try verifyEvent(.willDisplaySupplementaryViewForElementKindAtIndexPath, registration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self)
            sut.manager.willDisplaySupplementaryView(NibHeaderFooterView.self, forElementKind: UICollectionView.elementKindSectionHeader, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self) { $0.willDisplaySupplementaryView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setHeaderIntModels(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, willDisplaySupplementaryView: NibHeaderFooterView(), forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath(0, 0)))
        })
    }
    
    func testWillDisplayHeaderViewAtIndexPath() throws {
        try verifyEvent(.willDisplaySupplementaryViewForElementKindAtIndexPath, registration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self)
            sut.manager.willDisplayHeaderView(NibHeaderFooterView.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self) { $0.willDisplaySupplementaryView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setHeaderIntModels(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, willDisplaySupplementaryView: NibHeaderFooterView(), forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath(0, 0)))
        })
    }
    
    func testWillDisplayFooterViewAtIndexPath() throws {
        try verifyEvent(.willDisplaySupplementaryViewForElementKindAtIndexPath, registration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self)
            sut.manager.willDisplayFooterView(NibHeaderFooterView.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self) { $0.willDisplaySupplementaryView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setFooterIntModels(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, willDisplaySupplementaryView: NibHeaderFooterView(), forElementKind: UICollectionView.elementKindSectionFooter, at: indexPath(0, 0)))
        })
    }
    
    func testEndDisplayingItemAtIndexPath() throws {
        try verifyEvent(.didEndDisplayingCellForItemAtIndexPath, registration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self)
            sut.manager.didEndDisplaying(NibCell.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self) { $0.didEndDisplaying(self.fullfill(exp, andReturn: ()))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, didEndDisplaying: NibCell(), forItemAt: indexPath(0, 0)))
        })
    }
    
    func testDidEndDisplayingSupplementaryViewAtIndexPath() throws {
        try verifyEvent(.didEndDisplayingSupplementaryViewForElementKindAtIndexPath, registration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self)
            sut.manager.didEndDisplayingSupplementaryView(NibHeaderFooterView.self, forElementKind: UICollectionView.elementKindSectionHeader, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self) { $0.didEndDisplayingSupplementaryView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setHeaderIntModels(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, didEndDisplayingSupplementaryView: NibHeaderFooterView(), forElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath(0, 0)))
        })
    }
    
    func testDidEndDisplayingHeaderViewAtIndexPath() throws {
        try verifyEvent(.didEndDisplayingSupplementaryViewForElementKindAtIndexPath, registration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self)
            sut.manager.didEndDisplayingHeaderView(NibHeaderFooterView.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self) { $0.didEndDisplayingSupplementaryView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setHeaderIntModels(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, didEndDisplayingSupplementaryView: NibHeaderFooterView(), forElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath(0, 0)))
        })
    }
    
    func testEndDisplayingFooterViewAtIndexPath() throws {
        try verifyEvent(.didEndDisplayingSupplementaryViewForElementKindAtIndexPath, registration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self)
            sut.manager.didEndDisplayingFooterView(NibHeaderFooterView.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self) { $0.didEndDisplayingSupplementaryView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setFooterIntModels(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, didEndDisplayingSupplementaryView: NibHeaderFooterView(), forElementOfKind: UICollectionView.elementKindSectionFooter, at: indexPath(0, 0)))
        })
    }
    
    func testShouldShowMenuForItemAtIndexPath() {
        let exp = expectation(description: "shouldshowMenuForItemAtIndexPath")
        sut.manager.shouldShowMenu(for: NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView, shouldShowMenuForItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "canPerformActionForRowAtIndexPath")
        sut.manager.canPerformAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView, canPerformAction: #selector(testShouldShowMenuForItemAtIndexPath), forItemAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "performActionForItemAtIndexPath")
        sut.manager.performAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView, performAction: #selector(testShouldShowMenuForItemAtIndexPath), forItemAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available(tvOS 9.0, *)
    func testCanFocusItemAtIndexPath() throws {
        try verifyEvent(.canFocusItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.canFocus(NibCell.self, self.fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.canFocus(self.fullfill(exp, andReturn: true))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, canFocusItemAt: indexPath(0, 0)))
        }, expectedResult: true)
    }
    
    func testSizeForItemAtIndexPath() throws {
        try verifyEvent(.sizeForItemAtIndexPath,
        registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.sizeForCell(withItem: Int.self, fullfill(exp, andReturn: CGSize(width: 30, height: 30)))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) {
                $0.sizeForCell(self.fullfill(exp, andReturn: CGSize(width: 30, height: 30)))
            }
        }, preparation: addIntItem(), action: { (sut) in
            sut.manager.collectionDelegate?.collectionView(sut.collectionView, layout: UICollectionViewFlowLayout(), sizeForItemAt: indexPath(0, 0))
        }, expectedResult: CGSize(width: 30, height: 30))
    }
    
    func testSizeForHeaderInSection() throws {
        try verifyEvent(.referenceSizeForHeaderInSection, registration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self)
            sut.manager.referenceSizeForHeaderView(withItem: Int.self, fullfill(exp, andReturn: CGSize(width: 30, height: 30)))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self) {
                $0.referenceSizeForHeaderView(self.fullfill(exp, andReturn: CGSize(width: 30, height: 30)))
            }
        }, preparation: setHeaderIntModels(), action: { sut in
            sut.manager.collectionDelegate?.collectionView(sut.collectionView, layout: UICollectionViewFlowLayout(), referenceSizeForHeaderInSection: 0)
        }, expectedResult: CGSize(width: 30, height: 30))
    }
    
    func testSizeForFooterInSection() throws {
        try verifyEvent(.referenceSizeForFooterInSection, registration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self)
            sut.manager.referenceSizeForFooterView(withItem: Int.self, fullfill(exp, andReturn: CGSize(width: 30, height: 30)))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self) {
                $0.referenceSizeForFooterView(self.fullfill(exp, andReturn: CGSize(width: 30, height: 30)))
            }
        }, preparation: setFooterIntModels(), action: { sut in
            sut.manager.collectionDelegate?.collectionView(sut.collectionView, layout: UICollectionViewFlowLayout(), referenceSizeForFooterInSection: 0)
        }, expectedResult: CGSize(width: 30, height: 30))
    }
    
    func testMoveItemAtIndexPath() {
        let exp = expectation(description: "Move item at indexPath")
        sut.manager.moveItemAtTo { _,_ in
            exp.fulfill()
        }
        sut.manager.memoryStorage.addItems([3,4])
        _ = sut.manager.collectionDataSource?.collectionView(sut.collectionView, moveItemAt: indexPath(0, 0), to: indexPath(1, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available (tvOS 10.2, *)
    func testIndexTitlesForCollectionView() {
        let exp = expectation(description: "indexTitles for collectionView")
        sut.manager.indexTitles {
            exp.fulfill()
            return []
        }
        _ = sut.manager.collectionDataSource?.indexTitles(for: sut.collectionView)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available (tvOS 10.2, *)
    func testIndexPathForIndexTitle() {
        let exp = expectation(description: "indexPathForIndexTitle")
        sut.manager.indexPathForIndexTitle { _, _ in
            exp.fulfill()
            return indexPath(0, 0)
        }
        _ = sut.manager.collectionDataSource?.collectionView(sut.collectionView,
                                                             indexPathForIndexTitle: "",
                                                             at: 4)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testTransitionOldLayoutToNewLayout() {
        let exp = expectation(description: "transitionOldLayoutToNewLayout")
        sut.manager.transitionLayout { old, new in
            exp.fulfill()
            return UICollectionViewTransitionLayout(currentLayout: old, nextLayout: new)
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView,
                                                           transitionLayoutForOldLayout: UICollectionViewLayout(),
                                                           newLayout: UICollectionViewLayout())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testIndexPathForPreferredFocusView() {
        let exp = expectation(description: "indexPathForPreferredFocusedView")
        sut.manager.indexPathForPreferredFocusedView {
            exp.fulfill()
            return nil
        }
        _ = sut.manager.collectionDelegate?.indexPathForPreferredFocusedView(in: sut.collectionView)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testTargetIndexPathForMove() throws {
        try verifyEvent(.targetIndexPathForMoveFromItemAtTo, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.targetIndexPathForMovingItem(NibCell.self, fullfill(exp, andReturn: indexPath(0, 0)))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.targetIndexPathForMovingItem(self.fullfill(exp, andReturn: indexPath(0, 0)))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, targetIndexPathForMoveFromItemAt: indexPath(0, 0), toProposedIndexPath: indexPath(1, 0)))
        }, expectedResult: indexPath(0, 0))
    }
    
    func testTargetContentOffsetForProposedContentOffset() {
        let exp = expectation(description: "targetContentOffsetForProposedContentOffset")
        sut.manager.targetContentOffsetForProposedContentOffset { _ in
            exp.fulfill()
            return .zero
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView,
                                                           targetContentOffsetForProposedContentOffset: .zero)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #if os(iOS)
    func testShouldSpringLoadItem() throws {
        try verifyEvent(.shouldSpringLoadItem, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.shouldSpringLoad(NibCell.self, fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.shouldSpringLoad(self.fullfill(exp, andReturn: true))}
        }, preparation: {
            $0.manager.memoryStorage.addItems([3,4])
        }, action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, shouldSpringLoadItemAt: indexPath(0, 0), with: SpringLoadedContextMock()))
        }, expectedResult: true)
    }
    #endif
    
    func testCanEditItem() throws {
        guard #available(iOS 14, tvOS 14, *) else { throw XCTSkip() }
        try verifyEvent(.canEditItemAtIndexPath, registration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(UICollectionViewListCell.self, for: Int.self, handler: { _,_,_ in }, mapping: { $0.canEdit(self.fullfill(exp, andReturn: true)) })
        }, alternativeRegistration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(UICollectionViewListCell.self, for: Int.self, handler: { _,_,_ in}) { $0.canEdit(self.fullfill(exp, andReturn: true))}
        }, preparation: {
            $0.manager.memoryStorage.addItems([3,4])
        }, action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, canEditItemAt: indexPath(0, 0)))
        }, expectedResult: true)
    }
    
    func testInsetForSectionAtIndex() {
        let exp = expectation(description: "insetForSectionAtIndex")
        sut.manager.insetForSectionAtIndex { _,_ in
            exp.fulfill()
            return UIEdgeInsets()
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView,
                                                           layout: UICollectionViewLayout(),
                                                           insetForSectionAt: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMinimumLineSpacingForSectionAtIndex() {
        let exp = expectation(description: "minimumLineSpacingForSectionAtIndex")
        sut.manager.minimumLineSpacingForSectionAtIndex { _,_ in
            exp.fulfill()
            return 0
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView,
                                                           layout: UICollectionViewLayout(),
                                                           minimumLineSpacingForSectionAt: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMinimumInteritemSpacingForSectionAtIndex() {
        let exp = expectation(description: "minimumInteritemSpacingForSectionAtIndex")
        sut.manager.minimumInteritemSpacingForSectionAtIndex { _,_ in
            exp.fulfill()
            return 0
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView,
                                                           layout: UICollectionViewLayout(),
                                                           minimumInteritemSpacingForSectionAt: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK - UICollectionViewDragDelegate
    
    #if os(iOS)
    func testItemsForBeginningInDragSession() throws {
        try verifyEvent(.itemsForBeginningDragSessionAtIndexPath, registration: { sut, exp in
            sut.manager.register(NibCell.self)
            sut.manager.itemsForBeginningDragSession(from: NibCell.self, fullfill(exp, andReturn: []))
        }, alternativeRegistration: { sut, exp in
            sut.manager.register(NibCell.self) { mapping in
                mapping.itemsForBeginningDragSession(self.fullfill(exp, andReturn: []))
            }
        }, preparation: addIntItem(),
        action: {
            try XCTUnwrap($0.manager.collectionDragDelegate?.collectionView(sut.collectionView, itemsForBeginning: DragAndDropMock(), at: indexPath(0, 0)))
        }, expectedResult: [])
    }
    
    func testItemsForAddingToDragSession() throws {
        try verifyEvent(.itemsForAddingToDragSessionAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.itemsForAddingToDragSession(from: NibCell.self, fullfill(exp, andReturn: []))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) {
                $0.itemsForAddingToDragSession(self.fullfill(exp, andReturn: []))
            }
        }, preparation: addIntItem(),
        action: {
            try XCTUnwrap($0.manager.collectionDragDelegate?.collectionView(sut.collectionView, itemsForAddingTo: DragAndDropMock(), at: indexPath(0,0), point: .zero))
        }, expectedResult: [])
    }
    
    func testDragPreviewParametersForRowAtIndexPath() throws {
        try verifyEvent(.dragPreviewParametersForItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.dragPreviewParameters(for: NibCell.self, fullfill(exp, andReturn: nil))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { mapping in
                mapping.dragPreviewParameters(self.fullfill(exp, andReturn: nil))
            }
        }, preparation: addIntItem(), action: {
            $0.manager.collectionDragDelegate?.collectionView(sut.collectionView, dragPreviewParametersForItemAt: indexPath(0, 0))
        })
    }
    
    func testDragSessionWillBegin() {
        let exp = expectation(description: "dragSessionWillBegin")
        sut.manager.dragSessionWillBegin { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView, dragSessionWillBegin: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionDidEnd() {
        let exp = expectation(description: "dragSessionDidEnd")
        sut.manager.dragSessionDidEnd { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView, dragSessionDidEnd: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionAllowsMoveOperation() {
        let exp = expectation(description: "dragSessionAllowsMoveOperation")
        sut.manager.dragSessionAllowsMoveOperation{ _  in
            exp.fulfill()
            return true
        }
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView, dragSessionAllowsMoveOperation: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionIsRestrictedToDraggingApplication() {
        let exp = expectation(description: "dragSessionRestrictedToDraggingApplication")
        sut.manager.dragSessionIsRestrictedToDraggingApplication{ _  in
            exp.fulfill()
            return true
        }
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView, dragSessionIsRestrictedToDraggingApplication: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    /// MARK: - UITableViewDropDelegate
    
    func testPerformDropWithCoordinator() {
        let exp = expectation(description: "performDropWithCoordinator")
        sut.manager.performDropWithCoordinator { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView, performDropWith: DropCoordinatorMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanHandleDropSession() {
        let exp = expectation(description: "canHandleDropSession")
        sut.manager.canHandleDropSession { _ in
            exp.fulfill()
            return true
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView, canHandle: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidEnter() {
        let exp = expectation(description: "dropSessionDidEnter")
        sut.manager.dropSessionDidEnter { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView, dropSessionDidEnter: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidUpdate() {
        let exp = expectation(description: "dropSessionDidUpdate")
        sut.manager.dropSessionDidUpdate { _, _ in
            exp.fulfill()
            return UICollectionViewDropProposal(operation: .cancel)
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView, dropSessionDidUpdate: DragAndDropMock(), withDestinationIndexPath: nil)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidExit() {
        let exp = expectation(description: "dropSessionDidExit")
        sut.manager.dropSessionDidExit { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView, dropSessionDidExit: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidEnd() {
        let exp = expectation(description: "dropSessionDidEnd")
        sut.manager.dropSessionDidEnd { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView, dropSessionDidEnd: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropPreviewParametersForRowAtIndexPath() {
        let exp = expectation(description: "dropPreviewParametersForRowAtIndexPath")
        sut.manager.dropPreviewParameters { _ in
            exp.fulfill()
            return nil
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView, dropPreviewParametersForItemAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldBeginMultipleSelectionInteraction() throws {
        guard #available(iOS 13, *) else {
            throw XCTSkip()
        }
        try verifyEvent(.shouldBeginMultipleSelectionInteractionAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.shouldBeginMultipleSelectionInteraction(for: NibCell.self, fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.shouldBeginMultipleSelectionInteraction(self.fullfill(exp, andReturn: true))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, shouldBeginMultipleSelectionInteractionAt: indexPath(0, 0)))
        }, expectedResult: true)
    }
    
    func testDidBeginMultipleSelectionInteraction() throws {
        guard #available(iOS 13, *) else { throw XCTSkip() }
        try verifyEvent(.didBeginMultipleSelectionInteractionAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didBeginMultipleSelectionInteraction(for: NibCell.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didBeginMultipleSelectionInteraction(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.collectionDelegate?.collectionView(sut.collectionView, didBeginMultipleSelectionInteractionAt: indexPath(0, 0)))
        })
    }
    
    func testDidEndMultipleSelectionInteraction() throws {
        guard #available(iOS 13, *) else { throw XCTSkip() }
        let exp = expectation(description: "didEndMultipleSelectionInteractionAT")
        sut.manager.didEndMultipleSelectionInteraction {
            exp.fulfill()
        }
        sut.manager.memoryStorage.addItem(1)
        _ = sut.manager.collectionDelegate?.collectionViewDidEndMultipleSelectionInteraction(sut.collectionView)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testContextMenuConfiguration() throws {
        guard #available(iOS 13, *) else { throw XCTSkip() }
        try verifyEvent(.contextMenuConfigurationForItemAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.contextMenuConfiguration(for: NibCell.self, fullfill(exp, andReturn: nil))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.contextMenuConfiguration(self.fullfill(exp, andReturn: nil)) }
        }, preparation: addIntItem(), action: {
            $0.manager.collectionDelegate?.collectionView(sut.collectionView, contextMenuConfigurationForItemAt: indexPath(0,0), point: .zero)
        }, expectedResult: nil)
    }
    
    func testPreviewForHighlightingContextMenu() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "previewForHighlightingContextMenuWith")
        sut.manager.previewForHighlightingContextMenu { configuration in
            exp.fulfill()
            return nil
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView, previewForHighlightingContextMenuWithConfiguration: .init())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPreviewForDismissingContextMenu() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "previewForDismissingContextMenuWith")
        sut.manager.previewForDismissingContextMenu { configuration in
            exp.fulfill()
            return nil
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView, previewForDismissingContextMenuWithConfiguration: .init())
        waitForExpectations(timeout: 1, handler: nil)
    }
        #if compiler(<5.1.2)
    func testWillCommitMenuWithAnimator() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "willCommitMenuWithAnimator")
        sut.manager.willCommitMenuWithAnimator { animator in
            exp.fulfill()
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView, willCommitMenuWithAnimator: ContextMenuInteractionAnimatorMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
        #endif
    #endif
    
    #if os(tvOS)
    func testWillCenterItemAtIndexPath() throws {
        guard #available(tvOS 13, *) else { throw XCTSkip() }
        try verifyEvent(.willCenterCellAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.willCenter(NibCell.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.willCenter(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.collectionDelegate?.collectionView(sut.collectionView, layout: UICollectionViewLayout(), willCenterCellAt: indexPath(0, 0))
        })
    }
    
    func testDidCenterItemAtIndexPath() throws {
        guard #available(tvOS 13, *) else { throw XCTSkip() }
        try verifyEvent(.didCenterCellAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didCenter(NibCell.self, fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didCenter(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.collectionDelegate?.collectionView(sut.collectionView, layout: UICollectionViewLayout(), didCenterCellAt: indexPath(0, 0))
        })
    }
    #endif
    
    func testAllDelegateMethodSignatures() {
        if #available(tvOS 9, *) {
            XCTAssertEqual(String(describing: #selector(UICollectionViewDataSource.collectionView(_:canMoveItemAt:))), EventMethodSignature.canMoveItemAtIndexPath.rawValue)
        }
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:))), EventMethodSignature.shouldSelectItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:))), EventMethodSignature.didSelectItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:))), EventMethodSignature.shouldDeselectItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:))), EventMethodSignature.didDeselectItemAtIndexPath.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:))), EventMethodSignature.shouldHighlightItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:))), EventMethodSignature.didHighlightItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:))), EventMethodSignature.didUnhighlightItemAtIndexPath.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:))), EventMethodSignature.willDisplayCellForItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:))), EventMethodSignature.willDisplaySupplementaryViewForElementKindAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:))), EventMethodSignature.didEndDisplayingCellForItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:))), EventMethodSignature.didEndDisplayingSupplementaryViewForElementKindAtIndexPath.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:))), EventMethodSignature.shouldShowMenuForItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:))), EventMethodSignature.canPerformActionForItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:))), EventMethodSignature.performActionForItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:))), EventMethodSignature.transitionLayoutForOldLayoutNewLayout.rawValue)
        
        if #available(tvOS 9, *) {
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:canFocusItemAt:))), EventMethodSignature.canFocusItemAtIndexPath.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldUpdateFocusIn:))), EventMethodSignature.shouldUpdateFocusInContext.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didUpdateFocusIn:with:))), EventMethodSignature.didUpdateFocusInContext.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.indexPathForPreferredFocusedView(in:))), EventMethodSignature.indexPathForPreferredFocusedView.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:))), EventMethodSignature.targetIndexPathForMoveFromItemAtTo.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:))), EventMethodSignature.targetContentOffsetForProposedContentOffset.rawValue)
        }
        
        #if os(iOS)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldSpringLoadItemAt:with:))), EventMethodSignature.shouldSpringLoadItem.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UICollectionViewDragDelegate.collectionView(_:itemsForBeginning:at:))), EventMethodSignature.itemsForBeginningDragSessionAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDragDelegate.collectionView(_:itemsForAddingTo:at:point:))), EventMethodSignature.itemsForAddingToDragSessionAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDragDelegate.collectionView(_:dragPreviewParametersForItemAt:))), EventMethodSignature.dragPreviewParametersForItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDragDelegate.collectionView(_:dragSessionWillBegin:))), EventMethodSignature.dragSessionWillBegin.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDragDelegate.collectionView(_:dragSessionDidEnd:))), EventMethodSignature.dragSessionDidEnd.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDragDelegate.collectionView(_:dragSessionAllowsMoveOperation:))), EventMethodSignature.dragSessionAllowsMoveOperation.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDragDelegate.collectionView(_:dragSessionIsRestrictedToDraggingApplication:))), EventMethodSignature.dragSessionIsRestrictedToDraggingApplication.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UICollectionViewDropDelegate.collectionView(_:performDropWith:))), EventMethodSignature.performDropWithCoordinator.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDropDelegate.collectionView(_:canHandle:))), EventMethodSignature.canHandleDropSession.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDropDelegate.collectionView(_:dropSessionDidEnter:))), EventMethodSignature.dropSessionDidEnter.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDropDelegate.collectionView(_:dropSessionDidUpdate:withDestinationIndexPath:))), EventMethodSignature.dropSessionDidUpdate.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDropDelegate.collectionView(_:dropSessionDidExit:))), EventMethodSignature.dropSessionDidExit.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDropDelegate.collectionView(_:dropSessionDidEnd:))), EventMethodSignature.dropSessionDidEnd.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDropDelegate.collectionView(_:dropPreviewParametersForItemAt:))), EventMethodSignature.dropPreviewParametersForItemAtIndexPath.rawValue)
        
        if #available(iOS 13, *) {
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:shouldBeginMultipleSelectionInteractionAt:))), EventMethodSignature.shouldBeginMultipleSelectionInteractionAtIndexPath.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:didBeginMultipleSelectionInteractionAt:))), EventMethodSignature.didBeginMultipleSelectionInteractionAtIndexPath.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionViewDidEndMultipleSelectionInteraction(_:))), EventMethodSignature.didEndMultipleSelectionInteraction.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:contextMenuConfigurationForItemAt:point:))), EventMethodSignature.contextMenuConfigurationForItemAtIndexPath.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:previewForHighlightingContextMenuWithConfiguration:))), EventMethodSignature.previewForHighlightingContextMenu.rawValue)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:previewForDismissingContextMenuWithConfiguration:))), EventMethodSignature.previewForDismissingContextMenu.rawValue)
            #if compiler(<5.1.2)
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:willCommitMenuWithAnimator:))), EventMethodSignature.willCommitMenuWithAnimator.rawValue)
            #endif
        }
        #endif
        
        if #available(iOS 14, tvOS 14, *) {
            XCTAssertEqual(String(describing: #selector(UICollectionViewDelegate.collectionView(_:canEditItemAt:))), EventMethodSignature.canEditItemAtIndexPath.rawValue)
        }
        
        #if os(tvOS)
        if #available(tvOS 13, *) {
            XCTAssertEqual(String(describing: #selector(TVCollectionViewDelegateFullScreenLayout.collectionView(_:layout:willCenterCellAt:))), EventMethodSignature.willCenterCellAtIndexPath.rawValue)
            XCTAssertEqual(String(describing: #selector(TVCollectionViewDelegateFullScreenLayout.collectionView(_:layout:didCenterCellAt:))), EventMethodSignature.didCenterCellAtIndexPath.rawValue)
        }
        #endif
        
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))), EventMethodSignature.sizeForItemAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))), EventMethodSignature.insetForSectionAtIndex.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:))), EventMethodSignature.minimumLineSpacingForSectionAtIndex.rawValue)
        XCTAssertEqual(String(describing: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))), EventMethodSignature.minimumInteritemSpacingForSectionAtIndex.rawValue)
        
        // These methods are not equal on purpose - DTCollectionViewManager implements custom logic in them, and they are always implemented, even though they can act as events
        XCTAssertNotEqual(String(describing: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))), EventMethodSignature.referenceSizeForHeaderInSection.rawValue)
        XCTAssertNotEqual(String(describing: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))), EventMethodSignature.referenceSizeForFooterInSection.rawValue)
    }
    
    func testEventRegistrationPerfomance() {
        let manager = sut.manager
        manager.anomalyHandler.anomalyAction = { _ in }
        measure {
            manager.shouldSelect(NibCell.self, { _,_,_ in return true })
            manager.didSelect(NibCell.self, { _,_,_ in })
            manager.shouldDeselect(NibCell.self, { _,_,_ in return true })
            manager.didDeselect(NibCell.self, { _,_,_ in })
            manager.shouldHighlight(NibCell.self, { _,_,_ in return true })
            manager.didHighlight(NibCell.self, { _,_,_ in })
            manager.didUnhighlight(NibCell.self, { _,_,_ in })
            manager.willDisplay(NibCell.self, { _,_,_ in})
            manager.willDisplayHeaderView(NibHeaderFooterView.self, { _,_,_ in })
            manager.willDisplayFooterView(NibHeaderFooterView.self, { _,_,_ in })
            manager.willDisplaySupplementaryView(NibHeaderFooterView.self, forElementKind: "foo", {_,_,_ in })
            manager.didEndDisplaying(NibCell.self, { _,_,_ in })
            manager.didEndDisplayingHeaderView(NibHeaderFooterView.self, { _,_,_ in })
            manager.didEndDisplayingFooterView(NibHeaderFooterView.self, { _,_,_ in })
            manager.didEndDisplayingSupplementaryView(NibHeaderFooterView.self, forElementKind: "foo", { _,_,_ in })
            manager.shouldShowMenu(for: NibCell.self, { _,_,_ in return true })
            manager.canPerformAction(for: NibCell.self, { _,_,_,_,_ in return true })
            manager.performAction(for: NibCell.self, { _,_,_,_,_ in })
            manager.sizeForCell(withItem: Int.self, { _,_ in return .zero })
            manager.referenceSizeForHeaderView(withItem: Int.self, { _,_ in return .zero })
            manager.referenceSizeForFooterView(withItem: Int.self, { _,_ in return .zero })
        }
    }
    
    func testModelEventCalledWithCellTypeLeadsToAnomaly() {
        let exp = expectation(description: "Model event called with cell")
        let anomaly = DTCollectionViewManagerAnomaly.modelEventCalledWithCellClass(modelType: "NibCell", methodName: "sizeForCell(withItem:_:)", subclassOf: "UICollectionReusableView")
        sut.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        sut.manager.sizeForCell(withItem: NibCell.self) { _, _ in .zero }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "\n    ⚠️[DTCollectionViewManager] Event sizeForCell(withItem:_:) registered with model type, that happens to be a subclass of UICollectionReusableView: NibCell.\n\n    This is likely not what you want, because this event expects to receive model type used for current indexPath instead of cell/view.\n    Reasoning behind it is the fact that for some events views have not yet been created(for example: func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)).\n    Because they are not created yet, this event cannot be called with cell/view object, and even it\'s type is unknown at this point, as the mapping resolution will happen later.\n\n    Most likely you need to use model type, that will be passed to this cell/view through ModelTransfer protocol.\n    For example, for size of cell that expects to receive model Int, event would look like so:\n\n    manager.sizeForCell(withItem: Int.self) { model, indexPath in\n        return CGSize(height: 44, width: 44)\n    }\n")
    }
    
    func testUnusedEventLeadsToAnomaly() {
        let exp = expectation(description: "Unused event")
        let anomaly = DTCollectionViewManagerAnomaly.unusedEventDetected(viewType: "StringCell", methodName: "didSelect(_:_:)")
        sut.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        sut.manager.didSelect(StringCell.self) { _, _, _ in }
        waitForExpectations(timeout: 1.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTCollectionViewManager] didSelect(_:_:) event registered for StringCell, but there were no view mappings registered for StringCell type. This event will never be called.")
    }
}
