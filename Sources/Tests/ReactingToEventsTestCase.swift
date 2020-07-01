//
//  ReactingToEventsTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTCollectionViewManager

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
        controller.manager.register(SelectionReactingCollectionCell.self)
        
        var reactingCell : SelectionReactingCollectionCell?
        
        controller.manager.configure(SelectionReactingCollectionCell.self, { (cell, model, indexPath) in
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
    
    @available(tvOS 9.0, *)
    func testCanMoveItemAtIndexPath() {
        let exp = expectation(description: "canMoveItemAtIndexPath")
        sut.manager.canMove(NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionDataSource?.collectionView(sut.collectionView!, canMoveItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldSelectItemAtIndexPath() {
        let exp = expectation(description: "shouldSelectItemAtIndexPath")
        sut.manager.shouldSelect(NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, shouldSelectItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldDeselectItemAtIndexPath() {
        let exp = expectation(description: "shouldDeselectItemAtIndexPath")
        sut.manager.shouldDeselect(NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, shouldDeselectItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidDeselectItemAtIndexPath() {
        let exp = expectation(description: "didDeselectItemAtIndexPath")
        sut.manager.didDeselect(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, didDeselectItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldHighlightItemAtIndexPath() {
        let exp = expectation(description: "shouldHighlightItemAtIndexPath")
        sut.manager.shouldHighlight(NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, shouldHighlightItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidHighlightItemAtIndexPath() {
        let exp = expectation(description: "didHighlightItemAtIndexPath")
        sut.manager.didHighlight(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, didHighlightItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidUnhighlightItemAtIndexPath() {
        let exp = expectation(description: "didUnhighlightItemAtIndexPath")
        sut.manager.didUnhighlight(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, didUnhighlightItemAt: indexPath(0,0))
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
        sut.manager.willDisplaySupplementaryView(NibHeaderFooterView.self, forElementKind: DTCollectionViewElementSectionHeader, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, willDisplaySupplementaryView: NibHeaderFooterView(), forElementKind:DTCollectionViewElementSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayHeaderViewAtIndexPath() {
        let exp = expectation(description: "willDisplayHeaderViewAtIndexPath")
        sut.manager.willDisplayHeaderView(NibHeaderFooterView.self, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, willDisplaySupplementaryView: NibHeaderFooterView(), forElementKind:DTCollectionViewElementSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayFooterViewAtIndexPath() {
        let exp = expectation(description: "willDisplayHeaderViewAtIndexPath")
        sut.manager.willDisplayFooterView(NibHeaderFooterView.self, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionFooterModels([5])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, willDisplaySupplementaryView: NibHeaderFooterView(), forElementKind:DTCollectionViewElementSectionFooter, at: indexPath(0, 0))
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
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, didEndDisplaying: NibCell(), forItemAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingSupplementaryViewAtIndexPath() {
        let exp = expectation(description: "didEndDisplayingSupplementaryViewAtIndexPath")
        sut.manager.didEndDisplayingSupplementaryView(NibHeaderFooterView.self, forElementKind: DTCollectionViewElementSectionHeader, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, didEndDisplayingSupplementaryView: NibHeaderFooterView(), forElementOfKind:DTCollectionViewElementSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingHeaderViewAtIndexPath() {
        let exp = expectation(description: "didEndDisplayingHeaderViewAtIndexPath")
        sut.manager.didEndDisplayingHeaderView(NibHeaderFooterView.self, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, didEndDisplayingSupplementaryView: NibHeaderFooterView(), forElementOfKind:DTCollectionViewElementSectionHeader, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEndDisplayingFooterViewAtIndexPath() {
        let exp = expectation(description: "didEndDisplayingHeaderViewAtIndexPath")
        sut.manager.didEndDisplayingFooterView(NibHeaderFooterView.self, { view, model, section  in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.setSectionFooterModels([5])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, didEndDisplayingSupplementaryView: NibHeaderFooterView(), forElementOfKind:DTCollectionViewElementSectionFooter, at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldShowMenuForItemAtIndexPath() {
        let exp = expectation(description: "shouldshowMenuForItemAtIndexPath")
        sut.manager.shouldShowMenu(for: NibCell.self, { cell, model, indexPath -> Bool in
            exp.fulfill()
            return false
        })
        sut.manager.memoryStorage.addItem(3)
        
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, shouldShowMenuForItemAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "canPerformActionForRowAtIndexPath")
        sut.manager.canPerformAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, canPerformAction: #selector(testShouldShowMenuForItemAtIndexPath), forItemAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "performActionForItemAtIndexPath")
        sut.manager.performAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, performAction: #selector(testShouldShowMenuForItemAtIndexPath), forItemAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available(tvOS 9.0, *)
    func testCanFocusItemAtIndexPath() {
        let exp = expectation(description: "canFocusRowAtIndexPath")
        sut.manager.canFocus(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, canFocusItemAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSizeForItemAtIndexPath() {
        let exp = expectation(description: "sizeForItemAtIndexPath")
        sut.manager.sizeForCell(withItem: Int.self, { (model, indexPath) -> CGSize in
            exp.fulfill()
            return .zero
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, layout: UICollectionViewFlowLayout(), sizeForItemAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSizeForHeaderInSection() {
        let exp = expectation(description: "sizeForHeaderInSection")
        sut.manager.referenceSizeForHeaderView(withItem: Int.self, { (model, indexPath) -> CGSize in
            exp.fulfill()
            return .zero
        })
        sut.manager.memoryStorage.setSectionHeaderModels([5])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, layout: UICollectionViewFlowLayout(), referenceSizeForHeaderInSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSizeForFooterInSection() {
        let exp = expectation(description: "sizeForFooterInSection")
        sut.manager.referenceSizeForFooterView(withItem: Int.self, { (model, indexPath) -> CGSize in
            exp.fulfill()
            return .zero
        })
        sut.manager.memoryStorage.setSectionFooterModels([5])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!, layout: UICollectionViewFlowLayout(), referenceSizeForFooterInSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMoveItemAtIndexPath() {
        let exp = expectation(description: "Move item at indexPath")
        sut.manager.moveItemAtTo { _,_ in
            exp.fulfill()
        }
        sut.manager.memoryStorage.addItems([3,4])
        _ = sut.manager.collectionDataSource?.collectionView(sut.collectionView!, moveItemAt: indexPath(0, 0), to: indexPath(1, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available (tvOS 10.2, *)
    func testIndexTitlesForCollectionView() {
        let exp = expectation(description: "indexTitles for collectionView")
        sut.manager.indexTitles {
            exp.fulfill()
            return []
        }
        _ = sut.manager.collectionDataSource?.indexTitles(for: sut.collectionView!)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available (tvOS 10.2, *)
    func testIndexPathForIndexTitle() {
        let exp = expectation(description: "indexPathForIndexTitle")
        sut.manager.indexPathForIndexTitle { _, _ in
            exp.fulfill()
            return indexPath(0, 0)
        }
        _ = sut.manager.collectionDataSource?.collectionView(sut.collectionView!,
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
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!,
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
        _ = sut.manager.collectionDelegate?.indexPathForPreferredFocusedView(in: sut.collectionView!)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testTargetIndexPathForMove() {
        let exp = expectation(description: "TargetIndexPathForMove")
        sut.manager.targetIndexPathForMovingItem(NibCell.self) { _, _, _, _ in
            exp.fulfill()
            return IndexPath(item: 0, section: 0)
        }
        sut.manager.memoryStorage.addItems([3,4])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!,
                                                           targetIndexPathForMoveFromItemAt: indexPath(0, 0),
                                                           toProposedIndexPath: indexPath(1, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testTargetContentOffsetForProposedContentOffset() {
        let exp = expectation(description: "targetContentOffsetForProposedContentOffset")
        sut.manager.targetContentOffsetForProposedContentOffset { _ in
            exp.fulfill()
            return .zero
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!,
                                                           targetContentOffsetForProposedContentOffset: .zero)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #if os(iOS)
    func testShouldSpringLoadItem() {
        let exp = expectation(description: "shouldSpringLoadItem")
        sut.manager.shouldSpringLoad(NibCell.self) { _, _, _, _ in
            exp.fulfill()
            return true
        }
        sut.manager.memoryStorage.addItems([3,4])
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!,
                                                           shouldSpringLoadItemAt: indexPath(0, 0),
                                                           with: SpringLoadedContextMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif
    
    func testInsetForSectionAtIndex() {
        let exp = expectation(description: "insetForSectionAtIndex")
        sut.manager.insetForSectionAtIndex { _,_ in
            exp.fulfill()
            return UIEdgeInsets()
        }
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!,
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
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!,
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
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView!,
                                                           layout: UICollectionViewLayout(),
                                                           minimumInteritemSpacingForSectionAt: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK - UICollectionViewDragDelegate
    
    #if os(iOS)
    func testItemsForBeginningInDragSession() {
        let exp = expectation(description: "ItemsForBeginningInDragSession")
        sut.manager.itemsForBeginningDragSession(from: NibCell.self) { session, cell, model, _ in
            exp.fulfill()
            return []
        }
        sut.manager.memoryStorage.addItem(1)
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView!, itemsForBeginning: DragAndDropMock(), at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testItemsForAddingToDragSession() {
        let exp = expectation(description: "ItemsForAddingToDragSession")
        sut.manager.itemsForAddingToDragSession(from: NibCell.self) { session, point, cell, model, _ in
            exp.fulfill()
            return []
        }
        sut.manager.memoryStorage.addItem(1)
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView!, itemsForAddingTo: DragAndDropMock(), at: indexPath(0,0), point: .zero)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragPreviewParametersForRowAtIndexPath() {
        let exp = expectation(description: "dragPreviewParametersForRowAtIndexPath")
        sut.manager.dragPreviewParameters(for: NibCell.self) { cell, model, indexPath in
            exp.fulfill()
            return nil
        }
        sut.manager.memoryStorage.addItem(1)
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView!, dragPreviewParametersForItemAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionWillBegin() {
        let exp = expectation(description: "dragSessionWillBegin")
        sut.manager.dragSessionWillBegin { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView!, dragSessionWillBegin: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionDidEnd() {
        let exp = expectation(description: "dragSessionDidEnd")
        sut.manager.dragSessionDidEnd { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView!, dragSessionDidEnd: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionAllowsMoveOperation() {
        let exp = expectation(description: "dragSessionAllowsMoveOperation")
        sut.manager.dragSessionAllowsMoveOperation{ _  in
            exp.fulfill()
            return true
        }
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView!, dragSessionAllowsMoveOperation: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionIsRestrictedToDraggingApplication() {
        let exp = expectation(description: "dragSessionRestrictedToDraggingApplication")
        sut.manager.dragSessionIsRestrictedToDraggingApplication{ _  in
            exp.fulfill()
            return true
        }
        _ = sut.manager.collectionDragDelegate?.collectionView(sut.collectionView!, dragSessionIsRestrictedToDraggingApplication: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    /// MARK: - UITableViewDropDelegate
    
    func testPerformDropWithCoordinator() {
        let exp = expectation(description: "performDropWithCoordinator")
        sut.manager.performDropWithCoordinator { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView!, performDropWith: DropCoordinatorMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanHandleDropSession() {
        let exp = expectation(description: "canHandleDropSession")
        sut.manager.canHandleDropSession { _ in
            exp.fulfill()
            return true
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView!, canHandle: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidEnter() {
        let exp = expectation(description: "dropSessionDidEnter")
        sut.manager.dropSessionDidEnter { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView!, dropSessionDidEnter: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidUpdate() {
        let exp = expectation(description: "dropSessionDidUpdate")
        sut.manager.dropSessionDidUpdate { _, _ in
            exp.fulfill()
            return UICollectionViewDropProposal(operation: .cancel)
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView!, dropSessionDidUpdate: DragAndDropMock(), withDestinationIndexPath: nil)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidExit() {
        let exp = expectation(description: "dropSessionDidExit")
        sut.manager.dropSessionDidExit { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView!, dropSessionDidExit: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidEnd() {
        let exp = expectation(description: "dropSessionDidEnd")
        sut.manager.dropSessionDidEnd { _ in
            exp.fulfill()
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView!, dropSessionDidEnd: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropPreviewParametersForRowAtIndexPath() {
        let exp = expectation(description: "dropPreviewParametersForRowAtIndexPath")
        sut.manager.dropPreviewParameters { _ in
            exp.fulfill()
            return nil
        }
        _ = sut.manager.collectionDropDelegate?.collectionView(sut.collectionView!, dropPreviewParametersForItemAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldBeginMultipleSelectionInteraction() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "shouldBeginMultipleSelectionInteractionAT")
        sut.manager.shouldBeginMultipleSelectionInteraction(for: NibCell.self) { _,_,_ in
            exp.fulfill()
            return false
        }
        sut.manager.memoryStorage.addItem(1)
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView, shouldBeginMultipleSelectionInteractionAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidBeginMultipleSelectionInteraction() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "didBeginMultipleSelectionInteractionAT")
        sut.manager.didBeginMultipleSelectionInteraction(for: NibCell.self) { _,_,_ in
            exp.fulfill()
        }
        sut.manager.memoryStorage.addItem(1)
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView, didBeginMultipleSelectionInteractionAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndMultipleSelectionInteraction() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "didEndMultipleSelectionInteractionAT")
        sut.manager.didEndMultipleSelectionInteraction {
            exp.fulfill()
        }
        sut.manager.memoryStorage.addItem(1)
        _ = sut.manager.collectionDelegate?.collectionViewDidEndMultipleSelectionInteraction(sut.collectionView)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testContextMenuConfiguration() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "contextMenuConfiguration")
        sut.manager.contextMenuConfiguration(for: NibCell.self) { point, _, _, _ in
            XCTAssertEqual(point, CGPoint(x: 1, y: 1))
            exp.fulfill()
            return nil
        }
        sut.manager.memoryStorage.addItem(1)
        _ = sut.manager.collectionDelegate?.collectionView(sut.collectionView, contextMenuConfigurationForItemAt: indexPath(0, 0), point: CGPoint(x: 1, y: 1))
        waitForExpectations(timeout: 1, handler: nil)
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
