//
//  DTCollectionViewManager.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import DTModelStorage

/// Adopting this protocol will automatically inject manager property to your object, that lazily instantiates DTCollectionViewManager object.
/// Target is not required to be UICollectionViewController, and can be a regular UIViewController with UICollectionView, or even different object like UICollectionViewCell.
public protocol DTCollectionViewManageable : class
{
    /// Collection view, that will be managed by DTCollectionViewManager
    var collectionView : UICollectionView? { get }
}

/// This protocol is similar to `DTCollectionViewManageable`, but allows using non-optional `UICollectionView` property.
public protocol DTCollectionViewNonOptionalManageable : class {
    var collectionView : UICollectionView! { get }
}

private var DTCollectionViewManagerAssociatedKey = "DTCollectionView Manager Associated Key"

/// Default implementation for `DTCollectionViewManageable` protocol, that will inject `manager` property to any object, that declares itself `DTCollectionViewManageable`.
extension DTCollectionViewManageable
{
    /// Lazily instantiated `DTCollectionViewManager` instance. When your collection view is loaded, call `startManaging(withDelegate:)` method and `DTCollectionViewManager` will take over UICollectionView datasource and delegate.
    /// Any method, that is not implemented by `DTCollectionViewManager`, will be forwarded to delegate.
    /// If this property is accessed when UICollectionView is loaded, and DTCollectionViewManager is not configured yet, startManaging(withDelegate:_) method will automatically be called once to initialize DTCollectionViewManager.
    /// - SeeAlso: `startManaging(withDelegate:)`
    public var manager : DTCollectionViewManager {
        get {
            if let manager = objc_getAssociatedObject(self, &DTCollectionViewManagerAssociatedKey) as? DTCollectionViewManager {
                if !manager.isConfigured && collectionView != nil {
                    manager.startManaging(withDelegate: self)
                }
                return manager
            }
            let manager = DTCollectionViewManager()
            if collectionView != nil {
                manager.startManaging(withDelegate: self)
            }
            objc_setAssociatedObject(self, &DTCollectionViewManagerAssociatedKey, manager, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return manager
        }
        set {
            objc_setAssociatedObject(self, &DTCollectionViewManagerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// Default implementation for `DTCollectionViewManageable` protocol, that will inject `manager` property to any object, that declares itself `DTCollectionViewManageable`.
extension DTCollectionViewNonOptionalManageable
{
    /// Lazily instantiated `DTCollectionViewManager` instance. When your collection view is loaded, call `startManaging(withDelegate:)` method and `DTCollectionViewManager` will take over UICollectionView datasource and delegate.
    /// Any method, that is not implemented by `DTCollectionViewManager`, will be forwarded to delegate.
    /// - SeeAlso: `startManaging(withDelegate:)`
    public var manager : DTCollectionViewManager {
        get {
            if let manager = objc_getAssociatedObject(self, &DTCollectionViewManagerAssociatedKey) as? DTCollectionViewManager {
                if !manager.isConfigured && collectionView != nil {
                    manager.startManaging(withDelegate: self)
                }
                return manager
            }
            let manager = DTCollectionViewManager()
            if collectionView != nil {
                manager.startManaging(withDelegate: self)
            }
            objc_setAssociatedObject(self, &DTCollectionViewManagerAssociatedKey, manager, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return manager
        }
        set {
            objc_setAssociatedObject(self, &DTCollectionViewManagerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// `DTCollectionViewManager` manages most of `UICollectionView` datasource and delegate methods and provides API for managing your data models in the collection view. Any method, that is not implemented by `DTCollectionViewManager`, will be forwarded to delegate.
/// - SeeAlso: `startManagingWithDelegate:`
open class DTCollectionViewManager {
    
    var collectionView : UICollectionView? {
        if let delegate = delegate as? DTCollectionViewManageable { return delegate.collectionView }
        if let delegate = delegate as? DTCollectionViewNonOptionalManageable { return delegate.collectionView }
        return nil
    }
    
    /// Creates `DTCollectionViewManager`. Usually you don't need to call this method directly, as `manager` property on `DTCollectionViewManageable` instance is filled automatically.
    public init() {}
    
    fileprivate weak var delegate : AnyObject?
    
    /// Bool property, that will be true, after `startManagingWithDelegate` method is called on `DTCollectionViewManager`.
    open var isManagingCollectionView : Bool {
        return collectionView != nil
    }
    
    ///  Factory for creating cells and reusable views for UICollectionView
    final lazy var viewFactory: CollectionViewFactory = {
        precondition(self.isManagingCollectionView, "Please call manager.startManagingWithDelegate(self) before calling any other DTCollectionViewManager methods")
        //swiftlint:disable:next force_unwrapping
        let factory = CollectionViewFactory(collectionView: self.collectionView!)
        #if swift(>=4.1)
        factory.anomalyHandler = anomalyHandler
        #endif
        return factory
    }()
    
    /// Implicitly unwrap storage property to `MemoryStorage`.
    /// - Warning: if storage is not MemoryStorage, will throw an exception.
    open var memoryStorage : MemoryStorage! {
        precondition(storage is MemoryStorage, "DTCollectionViewManager memoryStorage method should be called only if you are using MemoryStorage")
        return storage as? MemoryStorage
    }
    
#if swift(>=4.1)
    /// Anomaly handler, that handles reported by `DTCollectionViewManager` anomalies.
    open var anomalyHandler : DTCollectionViewManagerAnomalyHandler = .init()
#endif
    
    /// Storage, that holds your UICollectionView models. By default, it's `MemoryStorage` instance.
    /// - Note: When setting custom storage for this property, it will be automatically configured for using with UICollectionViewFlowLayout and it's delegate will be set to `DTCollectionViewManager` instance.
    /// - Note: Previous storage `delegate` property will be nilled out to avoid collisions.
    /// - SeeAlso: `MemoryStorage`, `CoreDataStorage`.
    open var storage : Storage = {
        let storage = MemoryStorage()
        storage.configureForCollectionViewFlowLayoutUsage()
        return storage
        }()
        {
        willSet {
            storage.delegate = nil
        }
        didSet {
            if let headerFooterCompatibleStorage = storage as? BaseStorage {
                headerFooterCompatibleStorage.configureForCollectionViewFlowLayoutUsage()
            }
            storage.delegate = collectionViewUpdater
        }
    }
    
    /// Object, that is responsible for updating `UICollectionView`, when received update from `Storage`
    open var collectionViewUpdater : CollectionViewUpdater? {
        didSet {
            storage.delegate = collectionViewUpdater
            collectionViewUpdater?.didUpdateContent?(nil)
        }
    }
    
    /// Object, that is responsible for implementing `UICollectionViewDataSource` protocol
    open var collectionDataSource: DTCollectionViewDataSource? {
        didSet {
            collectionView?.dataSource = collectionDataSource
        }
    }
    
    /// Object, that is responsible for implementing `UICollectionViewDelegate` and `UICollectionViewDelegateFlowLayout` protocols
    open var collectionDelegate : DTCollectionViewDelegate? {
        didSet {
            collectionView?.delegate = collectionDelegate
        }
    }
    
    #if os(iOS) && swift(>=3.2)
    // Yeah, @availability macros does not work on stored properties ¯\_(ツ)_/¯
    private var _collectionDragDelegatePrivate : AnyObject?
    @available(iOS 11, *)
    /// Object, that is responsible for implementing `UICollectionViewDragDelegate` protocol
    open var collectionDragDelegate : DTCollectionViewDragDelegate? {
        get {
            return _collectionDragDelegatePrivate as? DTCollectionViewDragDelegate
        }
        set {
            _collectionDragDelegatePrivate = newValue
            collectionView?.dragDelegate = newValue
        }
    }
    
    // Yeah, @availability macros does not work on stored properties ¯\_(ツ)_/¯
    private var _collectionDropDelegatePrivate : AnyObject?
    @available(iOS 11, *)
    /// Object, that is responsible for implementing `UICOllectionViewDropDelegate` protocol
    open var collectionDropDelegate : DTCollectionViewDropDelegate? {
        get {
            return _collectionDropDelegatePrivate as? DTCollectionViewDropDelegate
        }
        set {
            _collectionDropDelegatePrivate = newValue
            collectionView?.dropDelegate = newValue
        }
    }
    #endif
    
    /// Call this method before calling any of `DTCollectionViewManager` methods.
    /// - Precondition: UICollectionView instance on `delegate` should not be nil.
    /// - Parameter delegate: Object, that has UICollectionView, that will be managed by `DTCollectionViewManager`.
    open func startManaging(withDelegate delegate : DTCollectionViewManageable)
    {
        guard !isConfigured else { return }
        guard let collectionView = delegate.collectionView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UICollectionView has been created")
        }
        self.delegate = delegate
        startManaging(with: collectionView)
    }
    
    /// Call this method before calling any of `DTCollectionViewManager` methods.
    /// - Precondition: UICollectionView instance on `delegate` should not be nil.
    /// - Parameter delegate: Object, that has UICollectionView, that will be managed by `DTCollectionViewManager`.
    open func startManaging(withDelegate delegate : DTCollectionViewNonOptionalManageable)
    {
        guard !isConfigured else { return }
        guard let collectionView = delegate.collectionView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UICollectionView has been created")
        }
        self.delegate = delegate
        startManaging(with: collectionView)
    }
    
    fileprivate var isConfigured = false
    
    fileprivate func startManaging(with collectionView: UICollectionView) {
        guard !isConfigured else { return }
        defer { isConfigured = true }
        if let mappingDelegate = delegate as? ViewModelMappingCustomizing {
            viewFactory.mappingCustomizableDelegate = mappingDelegate
        }
        collectionViewUpdater = CollectionViewUpdater(collectionView: collectionView)
        collectionDataSource = DTCollectionViewDataSource(delegate: delegate, collectionViewManager: self)
        collectionDelegate = DTCollectionViewDelegate(delegate: delegate, collectionViewManager: self)
        
        #if os(iOS) && swift(>=3.2)
        if #available(iOS 11.0, *) {
            collectionDragDelegate = DTCollectionViewDragDelegate(delegate: delegate, collectionViewManager: self)
            collectionDropDelegate = DTCollectionViewDropDelegate(delegate: delegate, collectionViewManager: self)
        }
        #endif
    }
    
    /// Returns closure, that updates cell at provided indexPath.
    ///
    /// This is used by `coreDataUpdater` method and can be used to silently update a cell without animation.
    open func updateCellClosure() -> (IndexPath, Any) -> Void {
        return { [weak self] indexPath, model in
            self?.viewFactory.updateCellAt(indexPath, with: model)
        }
    }
    
    /// Updates visible cells, using `collectionView.indexPathsForVisibleItems`, and update block. This may be more efficient than running `reloadData`, if number of your data models does not change, and the change you want to reflect is completely within models state.
    ///
    /// - Parameter closure: closure to run for each cell after update has been completed.
    open func updateVisibleCells(_ closure: ((UICollectionViewCell) -> Void)? = nil) {
        (collectionView?.indexPathsForVisibleItems ?? []).forEach { indexPath in
            guard let model = storage.item(at: indexPath),
                let visibleCell = collectionView?.cellForItem(at: indexPath)
                else { return }
            updateCellClosure()(indexPath, model)
            closure?(visibleCell)
        }
    }
    
    /// Returns `CollectionViewUpdater`, configured to work with `CoreDataStorage` and `NSFetchedResultsController` updates.
    ///
    /// - Precondition: UICollectionView instance on `delegate` should not be nil.
    open func coreDataUpdater() -> CollectionViewUpdater {
        guard let collectionView = self.collectionView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UICollectionView has been created")
        }
        return CollectionViewUpdater(collectionView: collectionView,
                                     reloadItem: updateCellClosure(),
                                     animateMoveAsDeleteAndInsert: true)
    }
    
    /// Immediately runs closure to provide access to both T and T.ModelType for `klass`.
    ///
    /// - Discussion: This is particularly useful for registering events, because near 1/3 of events don't have cell or view before they are getting run, which prevents view type from being known, and required developer to remember, which model is mapped to which cell.
    /// By using this container closure you will be able to provide compile-time safety for all events.
    /// - Parameters:
    ///   - klass: Class of reusable view to be used in configuration container
    ///   - closure: closure to run with view types.
    open func configureEvents<T:ModelTransfer>(for klass: T.Type, _ closure: (T.Type, T.ModelType.Type) -> Void) {
        closure(T.self, T.ModelType.self)
    }
    
    func verifyItemEvent<T>(for itemType: T.Type, methodName: String) {
        #if swift(>=4.1)
        switch itemType {
        case is UICollectionReusableView.Type:
            anomalyHandler.reportAnomaly(.modelEventCalledWithCellClass(modelType: String(describing: T.self), methodName: methodName, subclassOf: "UICollectionReusableView"))
        case is UITableViewCell.Type:
            anomalyHandler.reportAnomaly(.modelEventCalledWithCellClass(modelType: String(describing: T.self), methodName: methodName, subclassOf: "UITableViewCell"))
        case is UITableViewHeaderFooterView.Type: anomalyHandler.reportAnomaly(.modelEventCalledWithCellClass(modelType: String(describing: T.self), methodName: methodName, subclassOf: "UITableViewHeaderFooterView"))
        default: ()
        }
        #endif
    }
    
    func verifyViewEvent<T:ModelTransfer>(for viewType: T.Type, methodName: String) {
        #if swift(>=4.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if self?.viewFactory.mappings.filter({ $0.viewClass == T.self }).count == 0 {
                self?.anomalyHandler.reportAnomaly(DTCollectionViewManagerAnomaly.unusedEventDetected(viewType: String(describing: T.self), methodName: methodName))
            }
        }
        #endif
    }
}

/// All supported Objective-C method signatures.
///
/// Some of signatures are made up, so that we would be able to link them with event, however they don't stop "responds(to:)" method from returning true.
internal enum EventMethodSignature: String {
    /// UICollectionViewDataSource
    case configureCell = "collectionViewConfigureCell_imaginarySelector"
    case configureSupplementary = "collectionViewConfigureSupplementary_imaginarySelector"
    case canMoveItemAtIndexPath = "collectionView:canMoveItemAtIndexPath:"
    case moveItemAtIndexPathToIndexPath = "collectionView:moveItemAtIndexPath:toIndexPath:"
    case indexTitlesForCollectionView = "indexTitlesForCollectionView:"
    case indexPathForIndexTitleAtIndex = "collectionView:indexPathForIndexTitle:atIndex:"
    
    // UICollectionViewDelegate
    case shouldSelectItemAtIndexPath = "collectionView:shouldSelectItemAtIndexPath:"
    case didSelectItemAtIndexPath = "collectionView:didSelectItemAtIndexPath:"
    case shouldDeselectItemAtIndexPath = "collectionView:shouldDeselectItemAtIndexPath:"
    case didDeselectItemAtIndexPath = "collectionView:didDeselectItemAtIndexPath:"
    
    case shouldHighlightItemAtIndexPath = "collectionView:shouldHighlightItemAtIndexPath:"
    case didHighlightItemAtIndexPath = "collectionView:didHighlightItemAtIndexPath:"
    case didUnhighlightItemAtIndexPath = "collectionView:didUnhighlightItemAtIndexPath:"
    
    case willDisplayCellForItemAtIndexPath = "collectionView:willDisplayCell:forItemAtIndexPath:"
    case willDisplaySupplementaryViewForElementKindAtIndexPath = "collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:"
    case didEndDisplayingCellForItemAtIndexPath = "collectionView:didEndDisplayingCell:forItemAtIndexPath:"
    case didEndDisplayingSupplementaryViewForElementKindAtIndexPath = "collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:"
    
    case shouldShowMenuForItemAtIndexPath = "collectionView:shouldShowMenuForItemAtIndexPath:"
    case canPerformActionForItemAtIndexPath = "collectionView:canPerformAction:forItemAtIndexPath:withSender:"
    case performActionForItemAtIndexPath = "collectionView:performAction:forItemAtIndexPath:withSender:"
    
    case transitionLayoutForOldLayoutNewLayout = "collectionView:transitionLayoutForOldLayout:newLayout:"
    case canFocusItemAtIndexPath = "collectionView:canFocusItemAtIndexPath:"
    case shouldUpdateFocusInContext = "collectionView:shouldUpdateFocusInContext:"
    case didUpdateFocusInContext = "collectionView:didUpdateFocusInContext:withAnimationCoordinator:"
    case indexPathForPreferredFocusedView = "indexPathForPreferredFocusedViewInCollectionView:"
    case targetIndexPathForMoveFromItemAtTo = "collectionView:targetIndexPathForMoveFromItemAtIndexPath:toProposedIndexPath:"
    case targetContentOffsetForProposedContentOffset = "collectionView:targetContentOffsetForProposedContentOffset:"
    case shouldSpringLoadItem = "collectionView:shouldSpringLoadItemAtIndexPath:withContext:"
    
    // UICollectionViewDelegateFlowLayout
    case sizeForItemAtIndexPath = "collectionView:layout:sizeForItemAtIndexPath:"
    case referenceSizeForHeaderInSection = "collectionView:layout:referenceSizeForHeaderInSection:_imaginarySelector"
    case referenceSizeForFooterInSection = "collectionView:layout:referenceSizeForFooterInSection:_imaginarySelector"
    case insetForSectionAtIndex = "collectionView:layout:insetForSectionAtIndex:"
    case minimumLineSpacingForSectionAtIndex = "collectionView:layout:minimumLineSpacingForSectionAtIndex:"
    case minimumInteritemSpacingForSectionAtIndex = "collectionView:layout:minimumInteritemSpacingForSectionAtIndex:"
    
    // UICollectionViewDragDelegate
    
    case itemsForBeginningDragSessionAtIndexPath = "collectionView:itemsForBeginningDragSession:atIndexPath:"
    case itemsForAddingToDragSessionAtIndexPath = "collectionView:itemsForAddingToDragSession:atIndexPath:point:"
    case dragPreviewParametersForItemAtIndexPath = "collectionView:dragPreviewParametersForItemAtIndexPath:"
    case dragSessionWillBegin = "collectionView:dragSessionWillBegin:"
    case dragSessionDidEnd = "collectionView:dragSessionDidEnd:"
    case dragSessionAllowsMoveOperation = "collectionView:dragSessionAllowsMoveOperation:"
    case dragSessionIsRestrictedToDraggingApplication = "collectionView:dragSessionIsRestrictedToDraggingApplication:"
    
    // UICollectionViewDropDelegate
    
    case performDropWithCoordinator = "collectionView:performDropWithCoordinator:"
    case canHandleDropSession = "collectionView:canHandleDropSession:"
    case dropSessionDidEnter = "collectionView:dropSessionDidEnter:"
    case dropSessionDidUpdate = "collectionView:dropSessionDidUpdate:withDestinationIndexPath:"
    case dropSessionDidExit = "collectionView:dropSessionDidExit:"
    case dropSessionDidEnd = "collectionView:dropSessionDidEnd:"
    case dropPreviewParametersForItemAtIndexPath = "collectionView:dropPreviewParametersForItemAtIndexPath:"
}
