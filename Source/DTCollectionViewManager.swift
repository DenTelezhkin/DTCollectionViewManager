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
public protocol DTCollectionViewManageable : class, NSObjectProtocol
{
    /// Collection view, that will be managed by DTCollectionViewManager
    var collectionView : UICollectionView? { get }
}

/// This protocol is similar to `DTCollectionViewManageable`, but allows using non-optional `UICollectionView` property.
public protocol DTCollectionViewNonOptionalManageable : class, NSObjectProtocol {
    var collectionView : UICollectionView! { get }
}

private var DTCollectionViewManagerAssociatedKey = "DTCollectionView Manager Associated Key"

/// Default implementation for `DTCollectionViewManageable` protocol, that will inject `manager` property to any object, that declares itself `DTCollectionViewManageable`.
extension DTCollectionViewManageable
{
    /// Lazily instantiated `DTCollectionViewManager` instance. When your collection view is loaded, call `startManaging(withDelegate:)` method and `DTCollectionViewManager` will take over UICollectionView datasource and delegate. Any method, that is not implemented by `DTCollectionViewManager`, will be forwarded to delegate.
    /// - SeeAlso: `startManaging(withDelegate:)`
    public var manager : DTCollectionViewManager {
        get {
            if let manager = objc_getAssociatedObject(self, &DTCollectionViewManagerAssociatedKey) as? DTCollectionViewManager {
                return manager
            }
            let manager = DTCollectionViewManager()
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
    /// Lazily instantiated `DTCollectionViewManager` instance. When your collection view is loaded, call `startManaging(withDelegate:)` method and `DTCollectionViewManager` will take over UICollectionView datasource and delegate. Any method, that is not implemented by `DTCollectionViewManager`, will be forwarded to delegate.
    /// - SeeAlso: `startManaging(withDelegate:)`
    public var manager : DTCollectionViewManager {
        get {
            if let manager = objc_getAssociatedObject(self, &DTCollectionViewManagerAssociatedKey) as? DTCollectionViewManager {
                return manager
            }
            let manager = DTCollectionViewManager()
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
open class DTCollectionViewManager : NSObject {
    
    var collectionView : UICollectionView? {
        if let delegate = delegate as? DTCollectionViewManageable { return delegate.collectionView }
        if let delegate = delegate as? DTCollectionViewNonOptionalManageable { return delegate.collectionView }
        return nil
    }
    
    fileprivate weak var delegate : AnyObject?
    
    /// Bool property, that will be true, after `startManagingWithDelegate` method is called on `DTCollectionViewManager`.
    open var isManagingCollectionView : Bool {
        return collectionView != nil
    }
    
    ///  Factory for creating cells and reusable views for UICollectionView
    final lazy var viewFactory: CollectionViewFactory = {
        precondition(self.isManagingCollectionView, "Please call manager.startManagingWithDelegate(self) before calling any other DTCollectionViewManager methods")
        return CollectionViewFactory(collectionView: self.collectionView!)
    }()
    
    /// Error handler ot be executed when critical error happens with `CollectionViewFactory`.
    /// This can be useful to provide more debug information for crash logs, since preconditionFailure Swift method provides little to zero insight about what happened and when.
    /// This closure will be called prior to calling preconditionFailure in `handleCollectionViewFactoryError` method.
    @nonobjc open var viewFactoryErrorHandler : ((DTCollectionViewFactoryError) -> Void)?
    
    /// Implicitly unwrap storage property to `MemoryStorage`.
    /// - Warning: if storage is not MemoryStorage, will throw an exception.
    open var memoryStorage : MemoryStorage! {
        precondition(storage is MemoryStorage, "DTCollectionViewManager memoryStorage method should be called only if you are using MemoryStorage")
        return storage as! MemoryStorage
    }
    
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
    open var collectionViewUpdater : StorageUpdating? {
        didSet {
            storage.delegate = collectionViewUpdater
            (collectionViewUpdater as? CollectionViewUpdater)?.didUpdateContent?(nil)
        }
    }
    
    // Object, that is responsible for implementing `UICollectionViewDataSource` protocol
    open var collectionDataSource: DTCollectionViewDataSource? {
        didSet {
            collectionView?.dataSource = collectionDataSource
        }
    }
    
    // Object, that is responsible for implementing `UICollectionViewDelegate` and `UICollectionViewDelegateFlowLayout` protocols
    open var collectionDelegate : DTCollectionViewDelegate? {
        didSet {
            collectionView?.delegate = collectionDelegate
        }
    }
    
    /// Call this method before calling any of `DTCollectionViewManager` methods.
    /// - Precondition: UICollectionView instance on `delegate` should not be nil.
    /// - Parameter delegate: Object, that has UICollectionView, that will be managed by `DTCollectionViewManager`.
    open func startManaging(withDelegate delegate : DTCollectionViewManageable)
    {
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
        guard let collectionView = delegate.collectionView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UICollectionView has been created")
        }
        self.delegate = delegate
        startManaging(with: collectionView)
    }
    
    fileprivate func startManaging(with collectionView: UICollectionView) {
        if let mappingDelegate = delegate as? ViewModelMappingCustomizing {
            viewFactory.mappingCustomizableDelegate = mappingDelegate
        }
        collectionViewUpdater = CollectionViewUpdater(collectionView: collectionView)
        collectionDataSource = DTCollectionViewDataSource(delegate: delegate, collectionViewManager: self)
        collectionDelegate = DTCollectionViewDelegate(delegate: delegate, collectionViewManager: self)
        
        // Workaround, that prevents UICollectionView from being confused about it's own number of sections
        // This happens mostly on UICollectionView creation, before any delegate methods have been called and is not reproducible after it was fully initialized.
        // This is rare, and is not documented anywhere, but since workaround is small and harmless, we are including it
        // as a part of DTCollectionViewManager framework.
        _ = collectionView.numberOfSections
    }
    
    
    /// Returns closure, that updates cell at provided indexPath.
    ///
    /// This is used by `coreDataUpdater` method and can be used to silently update a cell without animation.
    open func updateCellClosure() -> (IndexPath,Any) -> Void {
        return { [weak self] indexPath, model in
            self?.viewFactory.updateCellAt(indexPath, with: model)
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
}

// MARK: - View registration
extension DTCollectionViewManager
{
    /// Registers mapping from model class to `cellClass`.
    ///
    /// Method will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class. If not - it is assumed that cell is registered in storyboard.
    /// - Note: If you need to create cell interface from code, use `registerNibless(_:)` method
    open func register<T:ModelTransfer>(_ cellClass:T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionViewCell
    {
        self.viewFactory.registerCellClass(cellClass, mappingBlock: mappingBlock)
    }
    
    /// Registers mapping from model class to `cellClass`.
    open func registerNibless<T:ModelTransfer>(_ cellClass:T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionViewCell
    {
        viewFactory.registerNiblessCellClass(cellClass, mappingBlock: mappingBlock)
    }
    
    /// Registers nib with `nibName` mapping from model class to `cellClass`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, for cellClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionViewCell
    {
        viewFactory.registerNibNamed(nibName, forCellClass: cellClass, mappingBlock: mappingBlock)
    }
    
    /// Registers mapping from model class to suppplementary view of `headerClass` type for UICollectionElementKindSectionHeader.
    ///
    /// Method will automatically check for nib with the same name as `headerClass`. If it exists - nib will be registered instead of class.
    open func registerHeader<T:ModelTransfer>(_ headerClass : T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: UICollectionElementKindSectionHeader, mappingBlock: mappingBlock)
    }
    
    /// Registers mapping from model class to suppplementary view of `footerClass` type for UICollectionElementKindSectionFooter.
    ///
    /// Method will automatically check for nib with the same name as `footerClass`. If it exists - nib will be registered instead of class.
    open func registerFooter<T:ModelTransfer>(_ footerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: UICollectionElementKindSectionFooter, mappingBlock: mappingBlock)
    }
    
    /// Registers mapping from model class to supplementary view of `headerClass` type with `nibName` for UICollectionElementKindSectionHeader.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forHeader headerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        viewFactory.registerNibNamed(nibName, forSupplementaryClass: T.self, forKind: UICollectionElementKindSectionHeader, mappingBlock: mappingBlock)
    }
    
    /// Registers mapping from model class to supplementary view of `footerClass` type with `nibName` for UICollectionElementKindSectionFooter.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forFooter footerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        viewFactory.registerNibNamed(nibName, forSupplementaryClass: T.self, forKind: UICollectionElementKindSectionFooter, mappingBlock: mappingBlock)
    }
    
    /// Registers mapping from model class to suppplementary view of `supplementaryClass` type for supplementary `kind`.
    ///
    /// Method will automatically check for nib with the same name as `supplementaryClass`. If it exists - nib will be registered instead of class.
    open func registerSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: kind, mappingBlock: mappingBlock)
    }
    
    /// Registers mapping from model class to supplementary view of `supplementaryClass` type with `nibName` for supplementary `kind`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forSupplementary supplementaryClass: T.Type, ofKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        viewFactory.registerNibNamed(nibName, forSupplementaryClass: T.self, forKind: kind, mappingBlock: mappingBlock)
    }
    
    /// Registers mapping from model class to supplementary view of `supplementaryClass` type for supplementary `kind`.
    open func registerNiblessSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
        viewFactory.registerNiblessSupplementaryClass(supplementaryClass, forKind: kind, mappingBlock: mappingBlock)
    }
    
    /// Registers mapping from model class to header view of `headerClass` type for `UICollectionElementKindSectionHeader`.
    open func registerNiblessHeader<T:ModelTransfer>(_ headerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
        registerNiblessSupplementary(T.self, forKind: UICollectionElementKindSectionHeader)
    }
    
    /// Registers mapping from model class to footer view of `footerClass` type for `UICollectionElementKindSectionFooter`.
    open func registerNiblessFooter<T:ModelTransfer>(_ footerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
        registerNiblessSupplementary(T.self, forKind: UICollectionElementKindSectionFooter)
    }
    
    /// Unregisters `cellClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregister<T:ModelTransfer>(_ cellClass: T.Type) where T: UICollectionViewCell {
        viewFactory.unregisterCellClass(T.self)
    }
    
    /// Unregisters `headerClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterHeader<T:ModelTransfer>(_ headerClass: T.Type) where T:UICollectionReusableView {
        unregisterSupplementary(T.self, forKind: UICollectionElementKindSectionHeader)
    }
    
    /// Unregisters `footerClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterFooter<T:ModelTransfer>(_ headerClass: T.Type) where T:UICollectionReusableView {
        unregisterSupplementary(T.self, forKind: UICollectionElementKindSectionFooter)
    }
    
    /// Unregisters `supplementaryClass` of `kind` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String) where T:UICollectionReusableView {
        viewFactory.unregisterSupplementaryClass(T.self, forKind: kind)
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
    
    case canFocusItemAtIndexPath = "collectionView:canFocusItemAtIndexPath:"
    
    // UICollectionViewDelegateFlowLayout
    case sizeForItemAtIndexPath = "collectionView:layout:sizeForItemAtIndexPath:"
    case referenceSizeForHeaderInSection = "collectionView:layout:referenceSizeForHeaderInSection:_imaginarySelector"
    case referenceSizeForFooterInSection = "collectionView:layout:referenceSizeForFooterInSection:_imaginarySelector"
}

// MARK: - Collection view reactions
extension DTCollectionViewManager
{
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:didSelectItemAt:)` method is called for `cellClass`.
    open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: .didSelectItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionView` requests `cellClass` in `UICollectionViewDataSource.collectionView(_:cellForItemAt:)` method and cell is being configured.
    ///
    /// This closure will be performed *after* cell is created and `update(with:)` method is called.
    open func configure<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        collectionDataSource?.appendReaction(for: T.self, signature: .configureCell, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionView` requests `headerClass` in `UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOf:at:)` method and header is being configured.
    ///
    /// This closure will be performed *after* header is created and `update(with:)` method is called.
    open func configureHeader<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UICollectionReusableView
    {
        let indexPathClosure : (T,T.ModelType, IndexPath) -> Void = { view, model, indexPath in
            closure(view,model, indexPath.section)
        }
        configureSupplementary(T.self, ofKind: UICollectionElementKindSectionHeader, indexPathClosure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionView` requests `footerClass` in `UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOf:at:)` method and footer is being configured.
    ///
    /// This closure will be performed *after* footer is created and `update(with:)` method is called.
    open func configureFooter<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UICollectionReusableView
    {
        let indexPathClosure : (T,T.ModelType, IndexPath) -> Void = { view, model, indexPath in
            closure(view,model, indexPath.section)
        }
        self.configureSupplementary(T.self, ofKind: UICollectionElementKindSectionFooter, indexPathClosure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionView` requests `supplementaryClass` of `kind` in `UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOf:at:)` method and supplementary view is being configured.
    ///
    /// This closure will be performed *after* supplementary view is created and `update(with:)` method is called.
    open func configureSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, ofKind kind: String, _ closure: @escaping (T,T.ModelType,IndexPath) -> Void) where T: UICollectionReusableView
    {
        collectionDataSource?.appendReaction(forSupplementaryKind: kind, supplementaryClass: T.self, signature: .configureSupplementary, closure: closure)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    /// Registers `closure` to be executed, when `UICollectionViewDataSource.collectionView(_:canMoveItemAt:)` method is called for `cellClass`.
    open func canMove<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        collectionDataSource?.appendReaction(for: T.self, signature: EventMethodSignature.canMoveItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:)` method is called for `cellClass`.
    open func shouldSelect<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.shouldSelectItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:)` method is called for `cellClass`.
    open func shouldDeselect<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.shouldDeselectItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)` method is called for `cellClass`.
    open func didDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: .didDeselectItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)` method is called for `cellClass`.
    open func shouldHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.shouldHighlightItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)` method is called for `cellClass`.
    open func didHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.didHighlightItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)` method is called for `cellClass`.
    open func didUnhighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.didUnhighlightItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:willDisplayCell:forItemAt:)` method is called for `cellClass`.
    open func willDisplay<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.willDisplayCellForItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)` method is called for `supplementaryClass` of `kind`.
    open func willDisplaySupplementaryView<T:ModelTransfer>(_ supplementaryClass:T.Type, forElementKind kind: String,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        collectionDelegate?.appendReaction(forSupplementaryKind: kind, supplementaryClass: T.self, signature: EventMethodSignature.willDisplaySupplementaryViewForElementKindAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)` method is called for `supplementaryClass` of `UICollectionElementKindSectionHeader`.
    open func willDisplayHeaderView<T:ModelTransfer>(_ headerClass:T.Type,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        willDisplaySupplementaryView(T.self, forElementKind: UICollectionElementKindSectionHeader, closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)` method is called for `supplementaryClass` of `UICollectionElementKindSectionFooter`.
    open func willDisplayFooterView<T:ModelTransfer>(_ footerClass:T.Type,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        willDisplaySupplementaryView(T.self, forElementKind: UICollectionElementKindSectionFooter, closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)` method is called for `cellClass`.
    open func didEndDisplaying<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.didEndDisplayingCellForItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementKind:at:)` method is called for `supplementaryClass` of `kind`.
    open func didEndDisplayingSupplementaryView<T:ModelTransfer>(_ supplementaryClass:T.Type, forElementKind kind: String,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        collectionDelegate?.appendReaction(forSupplementaryKind: kind, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingSupplementaryViewForElementKindAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementKind:at:)` method is called for `headerClass` of `UICollectionElementKindSectionHeader`.
    open func didEndDisplayingHeaderView<T:ModelTransfer>(_ headerClass:T.Type,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        didEndDisplayingSupplementaryView(T.self, forElementKind: UICollectionElementKindSectionHeader, closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementKind:at:)` method is called for `footerClass` of `UICollectionElementKindSectionFooter`.
    open func didEndDisplayingFooterView<T:ModelTransfer>(_ footerClass:T.Type,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        didEndDisplayingSupplementaryView(T.self, forElementKind: UICollectionElementKindSectionFooter, closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:shouldShowMenuForItemAt:)` method is called for `cellClass`.
    open func shouldShowMenu<T:ModelTransfer>(for cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.shouldShowMenuForItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:canPerformAction:forItemAt:withSender:)` method is called for `cellClass`.
    open func canPerformAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.canPerformActionForItemAtIndexPath.rawValue,
                                                  viewType: .cell,
                                                  viewClass: T.self)
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath -> Any in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender, cell, model, indexPath)
        }
        collectionDelegate?.collectionViewReactions.append(reaction)
    }
    
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:performAction:forItemAt:withSender:)` method is called for `cellClass`.
    open func performAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.performActionForItemAtIndexPath.rawValue,
                                                  viewType: .cell,
                                                  viewClass: T.self)
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath  in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender, cell, model, indexPath)
        }
        collectionDelegate?.collectionViewReactions.append(reaction)
    }
    
    @available(iOS 9, tvOS 9, *)
    /// Registers `closure` to be executed, when `UICollectionViewDelegate.collectionView(_:canFocusItemAt:)` method is called for `cellClass`.
    open func canFocus<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.canFocusItemAtIndexPath, closure: closure)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    /// Registers `closure` to be executed to determine cell size in `UICollectionViewDelegateFlowLayout.collectionView(_:sizeForItemAt:)` method, when it's called for cell which model is of `itemType`.
    open func sizeForCell<T>(withItem: T.Type, _ closure: @escaping (T, IndexPath) -> CGSize)
    {
        collectionDelegate?.appendReaction(for: T.self, signature: EventMethodSignature.sizeForItemAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine header size in `UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderViewInSection:)` method, when it's called for header which model is of `itemType`.
    open func referenceSizeForHeaderView<T>(withItem: T.Type, _ closure: @escaping (T, IndexPath) -> CGSize)
    {
        collectionDelegate?.appendReaction(forSupplementaryKind: UICollectionElementKindSectionHeader, modelClass: T.self, signature: EventMethodSignature.referenceSizeForHeaderInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine footer size in `UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterViewInSection:)` method, when it's called for footer which model is of `itemType`.
    open func referenceSizeForFooterView<T>(withItem: T.Type, _ closure: @escaping (T, IndexPath) -> CGSize)
    {
        collectionDelegate?.appendReaction(forSupplementaryKind: UICollectionElementKindSectionFooter, modelClass: T.self, signature: EventMethodSignature.referenceSizeForFooterInSection, closure: closure)
    }
}
