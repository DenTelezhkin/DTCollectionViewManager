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
    
    /// Boolean property, that indicates whether batch updates are completed. 
    /// - Note: this can be useful if you are deciding whether to run another batch of animations - insertion, deletions etc. UICollectionView is not very tolerant to multiple performBatchUpdates, executed at once.
    open var batchUpdatesInProgress = false
    
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
    open var storage : StorageProtocol = {
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
            storage.delegate = self
        }
    }
    
    /// Call this method before calling any of `DTCollectionViewManager` methods.
    /// - Precondition: UICollectionView instance on `delegate` should not be nil.
    /// - Parameter delegate: Object, that has UICollectionView, that will be managed by `DTCollectionViewManager`.
    open func startManagingWithDelegate(_ delegate : DTCollectionViewManageable)
    {
        precondition(delegate.collectionView != nil,"Call startManagingWithDelegate: method only when UICollectionView has been created")
        
        self.delegate = delegate
        delegate.collectionView?.delegate = self
        delegate.collectionView?.dataSource = self
        
        if let mappingDelegate = delegate as? DTViewModelMappingCustomizable {
            viewFactory.mappingCustomizableDelegate = mappingDelegate
        }
        storage.delegate = self
        
        // Workaround, that prevents UICollectionView from being confused about it's own number of sections
        // This happens mostly on UICollectionView creation, before any delegate methods have been called and is not reproducible after it was fully initialized.
        // This is rare, and is not documented anywhere, but since workaround is small and harmless, we are including it 
        // as a part of DTCollectionViewManager framework.
        _ = collectionView?.numberOfSections
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
}

internal enum EventMethodSignature: String {
    /// UICollectionViewDataSource
    case configureCell = "collectionViewConfigureCell_imaginarySelector"
    case configureSupplementary = "collectionViewConfigureSupplementary_imaginarySelector"
    case canMoveItemAtIndexPath = "collectionView:canMoveItemAtIndexPath:"
    
    // UICollectionViewDelegate
    case didSelectItemAtIndexPath = "collectionView:didSelectItemAtIndexPath:"
    
    // UICollectionViewDelegateFlowLayout
    
}

// MARK: - Collection view reactions
public extension DTCollectionViewManager
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
        guard let model = RuntimeHelper.recursivelyUnwrapAnyValue(storage.itemAtIndexPath(indexPath)) else {
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
        if let model = (self.storage as? SupplementaryStorageProtocol)?.supplementaryModelOfKind(kind, sectionIndexPath: indexPath) {
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
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        if let size = (self.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) {
            return size
        }
        if let _ = (storage as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(section) {
            return (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let size = (self.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) {
            return size
        }
        if let _ = (storage as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(section) {
            return (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        _ = performCellReaction(.didSelectItemAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    fileprivate func performCellReaction(_ signature: EventMethodSignature, location: IndexPath, provideCell: Bool) -> Any? {
        var cell : UICollectionViewCell?
        if provideCell { cell = collectionView?.cellForItem(at:location) }
        guard let model = storage.itemAtIndexPath(location) else { return nil }
        return collectionViewReactions.performReaction(ofType: .cell, signature: signature.rawValue, view: cell, model: model, location: location)
    }
    
    fileprivate func performSupplementaryReaction(forKind kind: String, signature: EventMethodSignature, location: IndexPath, view: UICollectionReusableView?) -> Any? {
        guard let model = (storage as? SupplementaryStorageProtocol)?.supplementaryModelOfKind(kind, sectionIndexPath: location) else { return nil }
        return collectionViewReactions.performReaction(ofType: .supplementary(kind: kind), signature: signature.rawValue, view: view, model: model, location: location)
    }
}

/// Conform to this protocol, if you want to monitor, when changes in storage are happening
public protocol DTCollectionViewContentUpdatable {
    func beforeContentUpdate()
    func afterContentUpdate()
}

public extension DTCollectionViewContentUpdatable where Self : DTCollectionViewManageable {
    func beforeContentUpdate() {}
    func afterContentUpdate() {}
}

// MARK : - StorageUpdating
extension DTCollectionViewManager : StorageUpdating
{
    open func storageDidPerformUpdate(_ update: StorageUpdate) {
        self.controllerWillUpdateContent()
        
        batchUpdatesInProgress = true
        
        collectionView?.performBatchUpdates({ [weak self] in
            if update.insertedRowIndexPaths.count > 0 { self?.collectionView?.insertItems(at: Array(update.insertedRowIndexPaths)) }
            if update.deletedRowIndexPaths.count > 0 { self?.collectionView?.deleteItems(at: Array(update.deletedRowIndexPaths)) }
            if update.updatedRowIndexPaths.count > 0 { self?.collectionView?.reloadItems(at: Array(update.updatedRowIndexPaths)) }
            if update.movedRowIndexPaths.count > 0 {
                for moveAction in update.movedRowIndexPaths {
                    if let from = moveAction.first, let to = moveAction.last {
                        self?.collectionView?.moveItem(at: from, to: to)
                    }
                }
            }
            
            if update.insertedSectionIndexes.count > 0 { self?.collectionView?.insertSections(update.insertedSectionIndexes.makeNSIndexSet()) }
            if update.deletedSectionIndexes.count > 0 { self?.collectionView?.deleteSections(update.deletedSectionIndexes.makeNSIndexSet()) }
            if update.updatedSectionIndexes.count > 0 { self?.collectionView?.reloadSections(update.updatedSectionIndexes.makeNSIndexSet())}
            if update.movedSectionIndexes.count > 0 {
                for moveAction in update.movedSectionIndexes {
                    if let from = moveAction.first, let to = moveAction.last {
                        self?.collectionView?.moveSection(from, toSection: to)
                    }
                }
            }
            }) { [weak self] finished in
                if update.insertedSectionIndexes.count + update.deletedSectionIndexes.count + update.updatedSectionIndexes.count > 0 {
                    self?.collectionView?.reloadData()
                }
                self?.batchUpdatesInProgress = false
        }
        self.controllerDidUpdateContent()
    }
    
    /// Call this method, if you want UICollectionView to be reloaded, and beforeContentUpdate: and afterContentUpdate: closures to be called.
    open func storageNeedsReloading() {
        self.controllerWillUpdateContent()
        collectionView?.reloadData()
        self.controllerDidUpdateContent()
    }
    
    private func controllerWillUpdateContent()
    {
        (self.delegate as? DTCollectionViewContentUpdatable)?.beforeContentUpdate()
    }
    
    private func controllerDidUpdateContent()
    {
        (self.delegate as? DTCollectionViewContentUpdatable)?.afterContentUpdate()
    }
}
