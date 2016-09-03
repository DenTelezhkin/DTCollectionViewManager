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

private var DTCollectionViewManagerAssociatedKey = "DTCollectionView Manager Associated Key"

/// Default implementation for `DTCollectionViewManageable` protocol, that will inject `manager` property to any object, that declares itself `DTCollectionViewManageable`.
extension DTCollectionViewManageable
{
    /// Lazily instantiated `DTCollectionViewManager` instance. When your collection view is loaded, call startManagingWithDelegate: method and `DTCollectionViewManager` will take over UICollectionView datasource and delegate. Any method, that is not implemented by `DTCollectionViewManager`, will be forwarded to delegate.
    /// - SeeAlso: `startManagingWithDelegate:`
    public var manager : DTCollectionViewManager
        {
        get {
            var object = objc_getAssociatedObject(self, &DTCollectionViewManagerAssociatedKey)
            if object == nil {
                object = DTCollectionViewManager()
                objc_setAssociatedObject(self, &DTCollectionViewManagerAssociatedKey, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return object as! DTCollectionViewManager
        }
        set {
            objc_setAssociatedObject(self, &DTCollectionViewManagerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// `DTCollectionViewManager` manages some of `UICollectionView` datasource and delegate methods and provides API for managing your data models in the collection view. Any method, that is not implemented by `DTCollectionViewManager`, will be forwarded to delegate.
/// - SeeAlso: `startManagingWithDelegate:`
open class DTCollectionViewManager : NSObject {
    
    fileprivate var collectionView : UICollectionView? {
        return self.delegate?.collectionView
    }
    
    fileprivate weak var delegate : DTCollectionViewManageable?
    
    /// Bool property, that will be true, after `startManagingWithDelegate` method is called on `DTCollectionViewManager`.
    open var isManagingCollectionView : Bool {
        return collectionView != nil
    }
    
    ///  Factory for creating cells and reusable views for UICollectionView
    final lazy var viewFactory: CollectionViewFactory = {
        precondition(self.isManagingCollectionView, "Please call manager.startManagingWithDelegate(self) before calling any other DTCollectionViewManager methods")
        return CollectionViewFactory(collectionView: self.collectionView!)
    }()
    
    /// Array of reactions for `DTCollectionViewManager`.
    /// - SeeAlso: `CollectionViewReaction`.
    fileprivate var collectionViewReactions = ContiguousArray<EventReaction>() {
        didSet {
            // Resetting delegate and dataSource are needed, because UICollectionView caches results of `respondsToSelector` call, and never calls it again until `setDelegate` method is called.
            // We force UICollectionView to flush that cache and query us again, because with new event we might have new delegate or datasource method to respond to.
            collectionView?.delegate = nil
            collectionView?.delegate = self
            
            // Workaround with number of sections prevents UICollectionView from crash on following lines, because it tries to find out number of sections and fails.
            collectionView?.dataSource = nil
            _ = collectionView?.numberOfSections
            collectionView?.dataSource = self
            _ = collectionView?.numberOfSections
        }
    }
    
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
            // explicit self is required due to known bug in Swift compiler - https://devforums.apple.com/message/1065306#1065306
            self.storage.delegate = nil
        }
        didSet {
            if let headerFooterCompatibleStorage = storage as? BaseStorage {
                headerFooterCompatibleStorage.configureForCollectionViewFlowLayoutUsage()
            }
            storage.delegate = collectionViewUpdater
        }
    }
    
    open var collectionViewUpdater : StorageUpdating? {
        didSet {
            storage.delegate = collectionViewUpdater
        }
    }
    
    /// Call this method before calling any of `DTCollectionViewManager` methods.
    /// - Precondition: UICollectionView instance on `delegate` should not be nil.
    /// - Parameter delegate: Object, that has UICollectionView, that will be managed by `DTCollectionViewManager`.
    open func startManagingWithDelegate(_ delegate : DTCollectionViewManageable)
    {
        guard let collectionView = delegate.collectionView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UICollectionView has been created")
        }
        
        self.delegate = delegate
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let mappingDelegate = delegate as? ViewModelMappingCustomizing {
            viewFactory.mappingCustomizableDelegate = mappingDelegate
        }
        collectionViewUpdater = CollectionViewUpdater(collectionView: collectionView)
        storage.delegate = collectionViewUpdater
        
        // Workaround, that prevents UICollectionView from being confused about it's own number of sections
        // This happens mostly on UICollectionView creation, before any delegate methods have been called and is not reproducible after it was fully initialized.
        // This is rare, and is not documented anywhere, but since workaround is small and harmless, we are including it 
        // as a part of DTCollectionViewManager framework.
        _ = collectionView.numberOfSections
    }
    
    open func updateCellClosure() -> (IndexPath) -> Void {
        return { [weak self] in
            guard let model = self?.storage.item(at: $0) else { return }
            self?.viewFactory.updateCellAt($0, with: model)
        }
    }
    
    open func coreDataUpdater() -> CollectionViewUpdater {
        guard let collectionView = delegate?.collectionView else {
            preconditionFailure("Call startManagingWithDelegate: method only when UICollectionView has been created")
        }
        return CollectionViewUpdater(collectionView: collectionView,
                                     reloadItem: updateCellClosure(),
                                     animateMoveAsDeleteAndInsert: true)
    }
}

// MARK: - Runtime forwarding
extension DTCollectionViewManager
{
    /// Any `UICollectionViewDatasource` and `UICollectionViewDelegate` method, that is not implemented by `DTCollectionViewManager` will be redirected to delegate, if it implements it.
    open override func forwardingTarget(for aSelector: Selector) -> Any? {
        return delegate
    }
    
    /// Any `UICollectionViewDatasource` and `UICollectionViewDelegate` method, that is not implemented by `DTCollectionViewManager` will be redirected to delegate, if it implements it.
    open override func responds(to aSelector: Selector) -> Bool {
        if self.delegate?.responds(to: aSelector) ?? false {
            return true
        }
        if super.responds(to: aSelector) {
            if let eventSelector = EventMethodSignature(rawValue: String(describing: aSelector)) {
                return collectionViewReactions.contains(where: { $0.methodSignature == eventSelector.rawValue })
            }
            return true
        }
        return false
    }
}

// MARK: - View registration
extension DTCollectionViewManager
{
    /// Register mapping from model class to custom cell class. Method will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter cellClass: Type of UICollectionViewCell subclass, that is being registered for using by `DTCollectionViewManager`
    open func registerCellClass<T:ModelTransfer>(_ cellClass:T.Type) where T: UICollectionViewCell
    {
        self.viewFactory.registerCellClass(cellClass)
    }
    
    /// Register mapping from model class to custom cell class. This method should be used, when you don't have cell interface created in XIB or storyboard, and you need cell, created from code.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter cellClass: Type of UICollectionViewCell subclass, that is being registered for using by `DTCollectionViewManager`
    open func registerNiblessCellClass<T:ModelTransfer>(_ cellClass:T.Type) where T: UICollectionViewCell
    {
        viewFactory.registerNiblessCellClass(cellClass)
    }
    
    /// Register mapping from model class to custom cell class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter cellClass: Type of UICollectionViewCell subclass, that is being registered for using by `DTCollectionViewManager`
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forCellClass cellClass: T.Type) where T: UICollectionViewCell
    {
        viewFactory.registerNibNamed(nibName, forCellClass: cellClass)
    }
    
    /// Register mapping from model class to custom header view class. Method will automatically check for nib with the same name as `headerClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter headerClass: Type of UICollectionViewCell subclass, that is being registered for using by `DTCollectionViewManager`
    open func registerHeaderClass<T:ModelTransfer>(_ headerClass : T.Type) where T: UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: UICollectionElementKindSectionHeader)
    }
    
    /// Register mapping from model class to custom footer view class. Method will automatically check for nib with the same name as `footerClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter footerClass: Type of UICollectionReusableView subclass, that is being registered for using by `DTCollectionViewManager`
    open func registerFooterClass<T:ModelTransfer>(_ footerClass: T.Type) where T:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: UICollectionElementKindSectionFooter)
    }
    
    /// Register mapping from model class to custom header class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter headerClass: Type of UICollectionReusableView subclass, that is being registered for using by `DTCollectionViewManager`
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forHeaderClass headerClass: T.Type) where T:UICollectionReusableView
    {
        viewFactory.registerNibNamed(nibName, forSupplementaryClass: T.self, forKind: UICollectionElementKindSectionHeader)
    }
    
    /// Register mapping from model class to custom footer class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter footerClass: Type of UICollectionReusableView subclass, that is being registered for using by `DTCollectionViewManager`
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forFooterClass footerClass: T.Type) where T:UICollectionReusableView
    {
        viewFactory.registerNibNamed(nibName, forSupplementaryClass: T.self, forKind: UICollectionElementKindSectionFooter)
    }
    
    /// Register mapping from model class to custom supplementary view class. Method will automatically check for nib with the same name as `supplementaryClass`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter supplementaryClass: Type of UICollectionReusableView subclass, that is being registered for using by `DTCollectionViewManager`
    /// - Parameter kind: Supplementary kind
    open func registerSupplementaryClass<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String) where T:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: kind)
    }
    
    /// Register mapping from model class to custom supplementary class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter supplementaryClass: Type of UICollectionReusableView subclass, that is being registered for using by `DTCollectionViewManager`
    /// - Parameter kind: Supplementary kind
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, supplementaryClass: T.Type, forKind kind: String) where T:UICollectionReusableView
    {
        viewFactory.registerNibNamed(nibName, forSupplementaryClass: supplementaryClass, forKind: kind)
    }
    
    /// Register mapping from model class to custom supplementary view class. This method should be used, when you don't have supplementary interface created in XIB or storyboard, and you need view, created from code.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter supplementaryClass: Type of UICollectionReusableView subclass, that is being registered for using by `DTCollectionViewManager`
    /// - Parameter kind: Supplementary kind
    open func registerNiblessSupplementaryClass<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String) where T:UICollectionReusableView {
        viewFactory.registerNiblessSupplementaryClass(supplementaryClass, forKind: kind)
    }
    
    open func unregisterCellClass<T:ModelTransfer>(_ cellClass: T.Type) where T: UICollectionViewCell {
        viewFactory.unregisterCellClass(T.self)
    }
    
    open func unregisterHeaderClass<T:ModelTransfer>(_ headerClass: T.Type) where T:UICollectionReusableView {
        unregisterSupplementaryClass(T.self, forKind: UICollectionElementKindSectionHeader)
    }
    
    open func unregisterFooterClass<T:ModelTransfer>(_ headerClass: T.Type) where T:UICollectionReusableView {
        unregisterSupplementaryClass(T.self, forKind: UICollectionElementKindSectionFooter)
    }
    
    open func unregisterSupplementaryClass<T:ModelTransfer>(_ klass: T.Type, forKind kind: String) where T:UICollectionReusableView {
        viewFactory.unregisterSupplementaryClass(T.self, forKind: kind)
    }
}

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
    fileprivate func appendReaction<T,U>(for cellClass: T.Type, signature: EventMethodSignature, closure: @escaping (T,T.ModelType, IndexPath) -> U) where T: ModelTransfer, T:UICollectionViewCell
    {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeCellReaction(closure)
        collectionViewReactions.append(reaction)
    }
    
    fileprivate func appendReaction<T,U>(for modelClass: T.Type, signature: EventMethodSignature, closure: @escaping (T, IndexPath) -> U)
    {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeCellReaction(closure)
        collectionViewReactions.append(reaction)
    }
    
    fileprivate func appendReaction<T,U>(forSupplementaryKind kind: String, supplementaryClass: T.Type, signature: EventMethodSignature, closure: @escaping (T, T.ModelType, IndexPath) -> U) where T: ModelTransfer, T: UICollectionReusableView {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeSupplementaryReaction(forKind: kind, block: closure)
        collectionViewReactions.append(reaction)
    }
    
    fileprivate func appendReaction<T,U>(forSupplementaryKind kind: String, modelClass: T.Type, signature: EventMethodSignature, closure: @escaping (T, IndexPath) -> U) {
        let reaction = EventReaction(signature: signature.rawValue)
        reaction.makeSupplementaryReaction(for: kind, block: closure)
        collectionViewReactions.append(reaction)
    }
    
    /// Define an action, that will be performed, when cell of specific type is selected.
    /// - Parameter cellClass: Type of UICollectionViewCell subclass
    /// - Parameter closure: closure to run when UICollectionViewCell is selected
    /// - Warning: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UICollectionViewCell
    {
        appendReaction(for: T.self, signature: .didSelectItemAtIndexPath, closure: closure)
    }
    
    @available(*, unavailable, renamed:"didSelect(_:_:)")
    open func whenSelected<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UICollectionViewCell
    {
        didSelect(cellClass, closure)
    }
    
    /// Define additional configuration action, that will happen, when UICollectionViewCell subclass is requested by UICollectionView. This action will be performed *after* cell is created and updateWithModel: method is called.
    /// - Parameter cellClass: Type of UICollectionViewCell subclass
    /// - Parameter closure: closure to run when UICollectionViewCell is being configured
    /// - Warning: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    open func configureCell<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: .configureCell, closure: closure)
    }
    
    /// Define additional configuration action, that will happen, when UICollectionReusableView header subclass is requested by UICollectionView. This action will be performed *after* header is created and updateWithModel: method is called.
    /// - Parameter headerClass: Type of UICollectionReusableView subclass
    /// - Parameter closure: closure to run when UICollectionReusableView is being configured
    /// - Warning: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    open func configureHeader<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UICollectionReusableView
    {
        let indexPathClosure : (T,T.ModelType, IndexPath) -> Void = { view, model, indexPath in
            closure(view,model, indexPath.section)
        }
        self.configureSupplementary(T.self, ofKind: UICollectionElementKindSectionHeader, indexPathClosure)
    }
    
    /// Define additional configuration action, that will happen, when UICollectionReusableView footer subclass is requested by UICollectionView. This action will be performed *after* footer is created and updateWithModel: method is called.
    /// - Parameter footerClass: Type of UICollectionReusableView subclass
    /// - Parameter closure: closure to run when UICollectionReusableView is being configured
    /// - Warning: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    open func configureFooter<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UICollectionReusableView
    {
        let indexPathClosure : (T,T.ModelType, IndexPath) -> Void = { view, model, indexPath in
            closure(view,model, indexPath.section)
        }
        self.configureSupplementary(T.self, ofKind: UICollectionElementKindSectionFooter, indexPathClosure)
    }
    
    /// Define additional configuration action, that will happen, when UICollectionReusableView supplementary subclass is requested by UICollectionView. This action will be performed *after* supplementary is created and updateWithModel: method is called.
    /// - Parameter supplementaryClass: Type of UICollectionReusableView subclass
    /// - Parameter closure: closure to run when UICollectionReusableView is being configured
    /// - Warning: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    open func configureSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, ofKind kind: String, _ closure: @escaping (T,T.ModelType,IndexPath) -> Void) where T: UICollectionReusableView
    {
        appendReaction(forSupplementaryKind: kind, supplementaryClass: T.self, signature: .configureSupplementary, closure: closure)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    open func canMove<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.canMoveItemAtIndexPath, closure: closure)
    }
    
    open func shouldSelect<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldSelectItemAtIndexPath, closure: closure)
    }
    
    open func shouldDeselect<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldDeselectItemAtIndexPath, closure: closure)
    }
    
    open func didDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UICollectionViewCell
    {
        appendReaction(for: T.self, signature: .didDeselectItemAtIndexPath, closure: closure)
    }
    
    open func shouldHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldHighlightItemAtIndexPath, closure: closure)
    }
    
    open func didHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didHighlightItemAtIndexPath, closure: closure)
    }
    
    open func didUnhighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didUnhighlightItemAtIndexPath, closure: closure)
    }
    
    open func willDisplay<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.willDisplayCellForItemAtIndexPath, closure: closure)
    }
    
    open func willDisplaySupplementaryView<T:ModelTransfer>(_ cellClass:T.Type, forElementKind kind: String,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        appendReaction(forSupplementaryKind: kind, supplementaryClass: T.self, signature: EventMethodSignature.willDisplaySupplementaryViewForElementKindAtIndexPath, closure: closure)
    }
    
    open func willDisplayHeaderView<T:ModelTransfer>(_ cellClass:T.Type,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        willDisplaySupplementaryView(T.self, forElementKind: UICollectionElementKindSectionHeader, closure)
    }
    
    open func willDisplayFooterView<T:ModelTransfer>(_ cellClass:T.Type,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        willDisplaySupplementaryView(T.self, forElementKind: UICollectionElementKindSectionFooter, closure)
    }
    
    open func didEndDisplaying<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.didEndDisplayingCellForItemAtIndexPath, closure: closure)
    }
    
    open func didEndDisplayingSupplementaryView<T:ModelTransfer>(_ cellClass:T.Type, forElementKind kind: String,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        appendReaction(forSupplementaryKind: kind, supplementaryClass: T.self, signature: EventMethodSignature.didEndDisplayingSupplementaryViewForElementKindAtIndexPath, closure: closure)
    }
    
    open func didEndDisplayingHeaderView<T:ModelTransfer>(_ cellClass:T.Type,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        didEndDisplayingSupplementaryView(T.self, forElementKind: UICollectionElementKindSectionHeader, closure)
    }
    
    open func didEndDisplayingFooterView<T:ModelTransfer>(_ cellClass:T.Type,_ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        didEndDisplayingSupplementaryView(T.self, forElementKind: UICollectionElementKindSectionFooter, closure)
    }
    
    open func shouldShowMenu<T:ModelTransfer>(for cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.shouldShowMenuForItemAtIndexPath, closure: closure)
    }
    
    open func canPerformAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.canPerformActionForItemAtIndexPath.rawValue)
        reaction.modelTypeCheckingBlock = { $0 is T.ModelType }
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath -> Any in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender, cell, model, indexPath)
        }
        collectionViewReactions.append(reaction)
    }
    
    open func performAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell {
        let reaction = FiveArgumentsEventReaction(signature: EventMethodSignature.performActionForItemAtIndexPath.rawValue)
        reaction.modelTypeCheckingBlock = { $0 is T.ModelType }
        reaction.reaction5Arguments = { selector, sender, cell, model, indexPath  in
            guard let selector = selector as? Selector,
                let cell = cell as? T,
                let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath
                else { return false }
            return closure(selector, sender, cell, model, indexPath)
        }
        collectionViewReactions.append(reaction)
    }
    
    @available(iOS 9, tvOS 9, *)
    open func canFocus<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UICollectionViewCell
    {
        appendReaction(for: T.self, signature: EventMethodSignature.canFocusItemAtIndexPath, closure: closure)
    }
    
    open func size<T>(_ forItemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGSize)
    {
        appendReaction(for: T.self, signature: EventMethodSignature.sizeForItemAtIndexPath, closure: closure)
    }
    
    open func referenceSizeForHeaderView<T>(_ withItemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGSize)
    {
        appendReaction(forSupplementaryKind: UICollectionElementKindSectionHeader, modelClass: T.self, signature: EventMethodSignature.referenceSizeForHeaderInSection, closure: closure)
    }
    
    open func referenceSizeForFooterView<T>(_ withItemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGSize)
    {
        appendReaction(forSupplementaryKind: UICollectionElementKindSectionFooter, modelClass: T.self, signature: EventMethodSignature.referenceSizeForFooterInSection, closure: closure)
    }
}

// MARK : - error handling

extension DTCollectionViewManager {
    @nonobjc final func handleCollectionViewFactoryError(_ error: DTCollectionViewFactoryError) {
        if let handler = viewFactoryErrorHandler {
            handler(error)
        } else {
            print(error.description)
            fatalError(error.description)
        }
    }
}

// MARK : - UICollectionViewDataSource
extension DTCollectionViewManager : UICollectionViewDataSource
{
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storage.sections[section].numberOfItems
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return storage.sections.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.item(at: indexPath)) else {
            handleCollectionViewFactoryError(DTCollectionViewFactoryError.nilCellModel(indexPath))
            return UICollectionViewCell()
        }
        
        let cell : UICollectionViewCell
        do {
            cell = try viewFactory.cellForModel(model, atIndexPath: indexPath)
        } catch let error as DTCollectionViewFactoryError {
            handleCollectionViewFactoryError(error)
            cell = UICollectionViewCell()
        } catch {
            cell = UICollectionViewCell()
        }
        _ = collectionViewReactions.performReaction(ofType: .cell,
                                                    signature: EventMethodSignature.configureCell.rawValue,
                                                    view: cell,
                                                    model: model,
                                                    location: indexPath)
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if let model = (self.storage as? SupplementaryStorage)?.supplementaryModel(ofKind: kind, forSectionAt: indexPath) {
            let view : UICollectionReusableView
            do {
                view = try viewFactory.supplementaryViewOfKind(kind, forModel: model, atIndexPath: indexPath)
            } catch let error as DTCollectionViewFactoryError {
                handleCollectionViewFactoryError(error)
                view = UICollectionReusableView()
            } catch {
                view = UICollectionReusableView()
            }
            _ = collectionViewReactions.performReaction(ofType: .supplementary(kind: kind),
                                                        signature: EventMethodSignature.configureSupplementary.rawValue,
                                                        view: view,
                                                        model: model,
                                                        location: indexPath)
            return view
        }
        handleCollectionViewFactoryError(.nilSupplementaryModel(kind: kind, indexPath: indexPath))
        fatalError()
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.canMoveItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDataSource)?.collectionView?(collectionView, canMoveItemAt: indexPath) ?? true
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    open func collectionView(_ collectionView: UICollectionView, moveItemAt source: IndexPath, to destination: IndexPath) {
        if (delegate as? UICollectionViewDataSource)?.collectionView?(collectionView, moveItemAt: source, to: destination) != nil {
            return
        }
        if let storage = self.storage as? MemoryStorage
        {
            if let from = storage.sections[source.section] as? SectionModel,
                let to = storage.sections[destination.section] as? SectionModel
            {
                let item = from.items[source.row]
                from.items.remove(at: source.row)
                to.items.insert(item, at: destination.row)
            }
        }
    }
}

// MARK : - UICollectionViewDelegateFlowLayout
extension DTCollectionViewManager : UICollectionViewDelegateFlowLayout
{
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = performCellReaction(.sizeForItemAtIndexPath, location: indexPath, provideCell: false) as? CGSize {
            return size
        }
        return (delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        if let size = performSupplementaryReaction(forKind: UICollectionElementKindSectionHeader, signature: .referenceSizeForHeaderInSection, location: IndexPath(item:0, section:section), view: nil) as? CGSize {
            return size
        }
        if let size = (self.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) {
            return size
        }
        if let _ = (storage as? HeaderFooterStorage)?.headerModel(forSection: section) {
            return (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let size = performSupplementaryReaction(forKind: UICollectionElementKindSectionFooter, signature: .referenceSizeForFooterInSection, location: IndexPath(item:0, section:section), view: nil) as? CGSize {
            return size
        }
        if let size = (self.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) {
            return size
        }
        if let _ = (storage as? HeaderFooterStorage)?.footerModel(forSection: section) {
            return (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.shouldSelectItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, shouldSelectItemAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        _ = performCellReaction(.didSelectItemAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.shouldDeselectItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, shouldDeselectItemAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        _ = performCellReaction(.didDeselectItemAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
    {
        _ = performCellReaction(.didHighlightItemAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didHighlightItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
    {
        _ = performCellReaction(.didUnhighlightItemAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didUnhighlightItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.shouldHighlightItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, shouldHighlightItemAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        defer { (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath) }
        guard let model = storage.item(at: indexPath) else { return }
        _ = collectionViewReactions.performReaction(ofType: .cell, signature: EventMethodSignature.willDisplayCellForItemAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        _ = performSupplementaryReaction(forKind: elementKind, signature: .willDisplaySupplementaryViewForElementKindAtIndexPath, location: indexPath, view: view)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        defer { (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath) }
        guard let model = storage.item(at: indexPath) else { return }
        _ = collectionViewReactions.performReaction(ofType: .cell, signature: EventMethodSignature.didEndDisplayingCellForItemAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        defer { (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath) }
        guard let model = (storage as? SupplementaryStorage)?.supplementaryModel(ofKind: elementKind, forSectionAt: indexPath) else { return }
        _ = collectionViewReactions.performReaction(ofType: .supplementary(kind: elementKind), signature: EventMethodSignature.didEndDisplayingSupplementaryViewForElementKindAtIndexPath.rawValue, view: view, model: model, location: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.shouldShowMenuForItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, shouldShowMenuForItemAt: indexPath) ?? false
    }
    
    open func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.item(at: indexPath)),
            let cell = collectionView.cellForItem(at: indexPath)
            else { return false }
        if let reaction = collectionViewReactions.reactionOfType(.cell, signature: EventMethodSignature.canPerformActionForItemAtIndexPath.rawValue, forModel: model) as? FiveArgumentsEventReaction {
            return reaction.performWithArguments((action,sender,cell,model,indexPath)) as? Bool ?? false
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender) ?? false
    }
    
    open func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        defer { (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, performAction: action, forItemAt: indexPath, withSender: sender) }
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.item(at: indexPath)),
            let cell = collectionView.cellForItem(at: indexPath)
            else { return }
        if let reaction = collectionViewReactions.reactionOfType(.cell, signature: EventMethodSignature.performActionForItemAtIndexPath.rawValue, forModel: model) as? FiveArgumentsEventReaction {
            _ = reaction.performWithArguments((action,sender,cell,model,indexPath))
        }
    }
    
    @available(iOS 9, tvOS 9, *)
    open func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.canFocusItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, canFocusItemAt: indexPath) ?? collectionView.cellForItem(at: indexPath)?.canBecomeFocused ?? true
    }

    fileprivate func performCellReaction(_ signature: EventMethodSignature, location: IndexPath, provideCell: Bool) -> Any? {
        var cell : UICollectionViewCell?
        if provideCell { cell = collectionView?.cellForItem(at:location) }
        guard let model = storage.item(at: location) else { return nil }
        return collectionViewReactions.performReaction(ofType: .cell, signature: signature.rawValue, view: cell, model: model, location: location)
    }
    
    fileprivate func performSupplementaryReaction(forKind kind: String, signature: EventMethodSignature, location: IndexPath, view: UICollectionReusableView?) -> Any? {
        guard let model = (storage as? SupplementaryStorage)?.supplementaryModel(ofKind: kind, forSectionAt: location) else { return nil }
        return collectionViewReactions.performReaction(ofType: .supplementary(kind: kind), signature: signature.rawValue, view: view, model: model, location: location)
    }
}
