//
//  DTCollectionViewManager.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

/// Adopting this protocol will automatically inject manager property to your object, that lazily instantiates DTCollectionViewManager object.
/// Target is not required to be UICollectionViewController, and can be a regular UIViewController with UICollectionView, or even different object like UICollectionViewCell.
public protocol DTCollectionViewManageable : NSObjectProtocol
{
    /// Collection view, that will be managed by DTCollectionViewManager
    var collectionView : UICollectionView! { get }
}

private var DTCollectionViewManagerAssociatedKey = "DTCollectionView Manager Associated Key"

/// Default implementation for `DTCollectionViewManageable` protocol, that will inject `manager` property to any object, that declares itself `DTCollectionViewManageable`.
extension DTCollectionViewManageable
{
    /// Lazily instantiated `DTCollectionViewManager` instance. When your table view is loaded, call startManagingWithDelegate: method and `DTCollectionViewManager` will take over UICollectionView datasource and delegate. Any method, that is not implemented by `DTCollectionViewManager`, will be forwarded to delegate.
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

/// `DTCollectionViewManager` manages some of `UICollectionView` datasource and delegate methods and provides API for managing your data models in the table. Any method, that is not implemented by `DTCollectionViewManager`, will be forwarded to delegate.
/// - SeeAlso: `startManagingWithDelegate:`
public class DTCollectionViewManager : NSObject {
    
    var collectionView : UICollectionView!
        {
            return self.delegate?.collectionView
    }
    
    weak var delegate : DTCollectionViewManageable?
    
    ///  Factory for creating cells and reusable views for UICollectionView
    private lazy var viewFactory: CollectionViewFactory = {
        precondition(self.collectionView != nil, "Please call manager.startManagingWithDelegate(self) before calling any other DTCollectionViewManager methods")
        return CollectionViewFactory(collectionView: self.collectionView)
    }()
    
    /// Bundle to search your xib's in. This can sometimes be useful for unit-testing. Defaults to NSBundle.mainBundle()
    public var viewBundle = NSBundle.mainBundle()
        {
        didSet {
            viewFactory.bundle = viewBundle
        }
    }
    
    /// Array of reactions for `DTCollectionViewManager`.
    /// - SeeAlso: `CollectionViewReaction`.
    var collectionViewReactions = [CollectionViewReaction]()
    
    func reactionOfReactionType(type: CollectionViewReactionType, forViewType viewType: _MirrorType? = nil, ofKind kind: String? = nil) -> CollectionViewReaction?
    {
        return self.collectionViewReactions.filter({ (reaction) -> Bool in
            return reaction.reactionType == type &&
                reaction.viewType?.summary == viewType?.summary &&
                reaction.kind == kind
        }).first
    }
    
    /// Implicitly unwrap storage property to `MemoryStorage`.
    /// - Warning: if storage is not MemoryStorage, will throw an exception.
    public var memoryStorage : MemoryStorage!
        {
            precondition(storage is MemoryStorage, "DTCollectionViewManager memoryStorage method should be called only if you are using MemoryStorage")
            
            return storage as! MemoryStorage
    }
    
    /// Storage, that holds your UICollectionView models. By default, it's `MemoryStorage` instance.
    /// - Note: When setting custom storage for this property, it will be automatically configured for using with UICollectionViewFlowLayout and it's delegate will be set to `DTCollectionViewManager` instance.
    /// - Note: Previous storage `delegate` property will be nilled out to avoid collisions.
    /// - SeeAlso: `MemoryStorage`, `CoreDataStorage`.
    public var storage : StorageProtocol = {
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
    public func startManagingWithDelegate(delegate : DTCollectionViewManageable)
    {
        precondition(delegate.collectionView != nil,"Call startManagingWithDelegate: method only when UICollectionView has been created")
        
        self.delegate = delegate
        delegate.collectionView.delegate = self
        delegate.collectionView.dataSource = self
    }
    
    /// Call this method to retrieve model from specific UICollectionViewCell subclass.
    /// - Note: This method uses UICollectionView `indexPathForCell` method, that returns nil if cell is not visible. Therefore, if cell is not visible, this method will return nil as well.
    /// - SeeAlso: `StorageProtocol` method `objectForCell:atIndexPath:` - will return model even if cell is not visible
    public func objectForCell<T:ModelTransfer where T:UICollectionViewCell>(cell:T?) -> T.ModelType?
    {
        guard cell != nil else {  return nil }
        
        if let indexPath = self.collectionView.indexPathForCell(cell!) {
            return storage.objectAtIndexPath(indexPath) as? T.ModelType
        }
        return nil
    }
}

// MARK: - Runtime forwarding
extension DTCollectionViewManager
{
    /// Any `UICollectionViewDatasource` and `UICollectionViewDelegate` method, that is not implemented by `DTCollectionViewManager` will be redirected to delegate, if it implements it.
    public override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return delegate
    }
    
    /// Any `UICollectionViewDatasource` and `UICollectionViewDelegate` method, that is not implemented by `DTCollectionViewManager` will be redirected to delegate, if it implements it.
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        if self.delegate?.respondsToSelector(aSelector) ?? false {
            return true
        }
        return super.respondsToSelector(aSelector)
    }
}

// MARK: - View registration
extension DTCollectionViewManager
{
    /// Register mapping from model class to custom cell class. Method will automatically check for nib with the same name as `cellType`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter cellType: Type of UICollectionViewCell subclass, that is being registered for using by `DTCollectionViewManager`
    public func registerCellClass<T:ModelTransfer where T: UICollectionViewCell>(cellType:T.Type)
    {
        self.viewFactory.registerCellClass(cellType)
    }
    
    /// This method combines registerCellClass and whenSelected: methods together.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter cellType: Type of UICollectionViewCell subclass, that is being registered for using by `DTCollectionViewManager`
    /// - Parameter selectionClosure: closure to run when UICollectionViewCell is selected
    /// - Note: selectionClosure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    /// - SeeAlso: `registerCellClass`, `whenSelected` methods
    public func registerCellClass<T:ModelTransfer where T:UICollectionViewCell>(cellType: T.Type,
        selectionClosure: (T,T.ModelType, NSIndexPath) -> Void)
    {
        viewFactory.registerCellClass(cellType)
        self.whenSelected(cellType, selectionClosure)
    }
    
    /// Register mapping from model class to custom cell class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter cellType: Type of UICollectionViewCell subclass, that is being registered for using by `DTCollectionViewManager`
    public func registerNibNamed<T:ModelTransfer where T: UICollectionViewCell>(nibName: String, forCellType cellType: T.Type)
    {
        viewFactory.registerNibNamed(nibName, forCellType: cellType)
    }
    
    /// Register mapping from model class to custom header view class. Method will automatically check for nib with the same name as `headerType`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter headerType: Type of UICollectionViewCell subclass, that is being registered for using by `DTCollectionViewManager`
    public func registerHeaderClass<T:ModelTransfer where T: UICollectionReusableView>(headerType : T.Type)
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: UICollectionElementKindSectionHeader)
    }
    
    /// Register mapping from model class to custom footer view class. Method will automatically check for nib with the same name as `footerType`. If it exists - nib will be registered instead of class.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter footerType: Type of UICollectionReusableView subclass, that is being registered for using by `DTCollectionViewManager`
    public func registerFooterClass<T:ModelTransfer where T:UICollectionReusableView>(footerType: T.Type)
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: UICollectionElementKindSectionFooter)
    }
    
    /// Register mapping from model class to custom header class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter headerType: Type of UICollectionReusableView subclass, that is being registered for using by `DTCollectionViewManager`
    public func registerNibNamed<T:ModelTransfer where T:UICollectionReusableView>(nibName: String, forHeaderType headerType: T.Type)
    {
        viewFactory.registerNibNamed(nibName, forSupplementaryClass: T.self, forKind: UICollectionElementKindSectionHeader)
    }
    
    /// Register mapping from model class to custom footer class using specific nib file.
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Parameter nibName: Name of xib file to use
    /// - Parameter footerType: Type of UICollectionReusableView subclass, that is being registered for using by `DTCollectionViewManager`
    public func registerNibNamed<T:ModelTransfer where T:UICollectionReusableView>(nibName: String, forFooterType footerType: T.Type)
    {
        viewFactory.registerNibNamed(nibName, forSupplementaryClass: T.self, forKind: UICollectionElementKindSectionFooter)
    }
    
    public func registerSupplementaryClass<T:ModelTransfer where T:UICollectionReusableView>(supplementaryClass: T.Type, forKind kind: String)
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: kind)
    }
    
    public func registerNibNamed<T:ModelTransfer where T:UICollectionReusableView>(nibName: String, supplementaryClass: T.Type, forKind kind: String)
    {
        viewFactory.registerNibNamed(nibName, forSupplementaryClass: supplementaryClass, forKind: kind)
    }
    
}

// MARK: - Collection view reactions
public extension DTCollectionViewManager
{
    /// Define an action, that will be performed, when cell of specific type is selected.
    /// - Parameter cellClass: Type of UICollectionViewCell subclass
    /// - Parameter closure: closure to run when UICollectionViewCell is selected
    /// - Note: Model type is automatically gathered from `ModelTransfer`.`ModelType` associated type.
    /// - Note: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    /// - SeeAlso: `registerCellClass:selectionClosure` method
    func whenSelected<T:ModelTransfer where T:UICollectionViewCell>(cellClass:  T.Type, _ closure: (T,T.ModelType, NSIndexPath) -> Void)
    {
        let reaction = CollectionViewReaction(reactionType: .Selection)
        reaction.viewType = _reflect(T)
        reaction.reactionBlock = { [weak self, reaction] in
            if let indexPath = reaction.reactionData as? NSIndexPath,
                let cell = self?.collectionView.cellForItemAtIndexPath(indexPath),
                let model = self?.storage.objectAtIndexPath(indexPath)
            {
                closure(cell as! T, model as! T.ModelType, indexPath)
            }
        }
        self.collectionViewReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UICollectionViewCell subclass is requested by UICollectionView. This action will be performed *after* cell is created and updateWithModel: method is called.
    /// - Parameter cellClass: Type of UICollectionViewCell subclass
    /// - Parameter closure: closure to run when UICollectionViewCell is being configured
    /// - Note: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    public func configureCell<T:ModelTransfer where T: UICollectionViewCell>(cellClass:T.Type, _ closure: (T, T.ModelType, NSIndexPath) -> Void)
    {
        let reaction = CollectionViewReaction(reactionType: .CellConfiguration)
        reaction.viewType = _reflect(T)
        reaction.reactionBlock = { [weak self, reaction] in
            if let configuration = reaction.reactionData as? ViewConfiguration,
                let model = self?.storage.objectAtIndexPath(configuration.indexPath)
            {
                closure(configuration.view as! T, model as! T.ModelType, configuration.indexPath)
            }
        }
        self.collectionViewReactions.append(reaction)
    }
    
    /// Define additional configuration action, that will happen, when UICollectionReusableView header subclass is requested by UICollectionView. This action will be performed *after* header is created and updateWithModel: method is called.
    /// - Parameter headerClass: Type of UICollectionReusableView subclass
    /// - Parameter closure: closure to run when UICollectionReusableView is being configured
    /// - Note: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    public func configureHeader<T:ModelTransfer where T: UICollectionReusableView>(headerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        self.configureSupplementary(T.self, ofKind: UICollectionElementKindSectionHeader, closure)
    }
    
    /// Define additional configuration action, that will happen, when UICollectionReusableView footer subclass is requested by UICollectionView. This action will be performed *after* footer is created and updateWithModel: method is called.
    /// - Parameter footerClass: Type of UICollectionReusableView subclass
    /// - Parameter closure: closure to run when UICollectionReusableView is being configured
    /// - Note: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    public func configureFooter<T:ModelTransfer where T: UICollectionReusableView>(footerClass: T.Type, _ closure: (T, T.ModelType, Int) -> Void)
    {
        self.configureSupplementary(T.self, ofKind: UICollectionElementKindSectionFooter, closure)
    }
    
    public func configureSupplementary<T:ModelTransfer where T: UICollectionReusableView>(supplementaryClass: T.Type, ofKind kind: String, _ closure: (T,T.ModelType,Int) -> Void)
    {
        let reaction = CollectionViewReaction(reactionType: .SupplementaryConfiguration)
        reaction.kind = kind
        reaction.viewType = _reflect(T)
        reaction.reactionBlock = { [weak self, reaction] in
            if let configuration = reaction.reactionData as? ViewConfiguration,
                let headerStorage = self?.storage as? HeaderFooterStorageProtocol,
                let model = headerStorage.headerModelForSectionIndex(configuration.indexPath.section)
            {
                closure(configuration.view as! T, model as! T.ModelType, configuration.indexPath.section)
            }
        }
        self.collectionViewReactions.append(reaction)
    }
    
    /// Perform action before content will be updated.
    /// - Note: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    public func beforeContentUpdate(block: () -> Void )
    {
        let reaction = CollectionViewReaction(reactionType: .ControllerWillUpdateContent)
        reaction.reactionBlock = block
        self.collectionViewReactions.append(reaction)
    }
    
    /// Perform action after content is updated.
    /// - Note: Closure will be stored on `DTCollectionViewManager` instance, which can create a retain cycle, so make sure to declare weak self and any other `DTCollectionViewManager` property in capture lists.
    public func afterContentUpdate(block : () -> Void )
    {
        let reaction = CollectionViewReaction(reactionType: .ControllerDidUpdateContent)
        reaction.reactionBlock = block
        self.collectionViewReactions.append(reaction)
    }
}

extension DTCollectionViewManager : UICollectionViewDataSource
{
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storage.sections[section].numberOfObjects
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return storage.sections.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let model = storage.objectAtIndexPath(indexPath)
        let cell = viewFactory.cellForModel(model, atIndexPath: indexPath)
        if let reaction = self.reactionOfReactionType(.CellConfiguration, forViewType: _reflect(cell.dynamicType)) {
            reaction.reactionData = ViewConfiguration(view: cell, indexPath:indexPath)
            reaction.perform()
        }
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        if let model = (self.storage as? SupplementaryStorageProtocol)?.supplementaryModelOfKind(kind, sectionIndex: indexPath.section) {
            let view = viewFactory.supplementaryViewOfKind(kind, forModel: model, atIndexPath: indexPath)
            if let reaction = self.reactionOfReactionType(.SupplementaryConfiguration, forViewType: _reflect(view.dynamicType), ofKind: kind) {
                reaction.reactionData = ViewConfiguration(view: view, indexPath:indexPath)
                reaction.perform()
            }
            return view
        }
        return UICollectionReusableView()
    }
}

extension DTCollectionViewManager : UICollectionViewDelegateFlowLayout
{
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        if let size = (self.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) {
            return size
        }
        if let _ = (storage as? SupplementaryStorageProtocol)?.supplementaryModelOfKind(UICollectionElementKindSectionHeader, sectionIndex: section) {
            return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
        }
        return CGSizeZero
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let size = (self.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) {
            return size
        }
        if let _ = (storage as? SupplementaryStorageProtocol)?.supplementaryModelOfKind(UICollectionElementKindSectionFooter, sectionIndex: section) {
            return (collectionViewLayout as! UICollectionViewFlowLayout).footerReferenceSize
        }
        return CGSizeZero
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        if let reaction = self.reactionOfReactionType(.Selection, forViewType: _reflect(cell.dynamicType)) {
            reaction.reactionData = indexPath
            reaction.perform()
        }
    }
}

extension DTCollectionViewManager : StorageUpdating
{
    public func storageDidPerformUpdate(update: StorageUpdate) {
        self.controllerWillUpdateContent()
        
        let sectionsToInsert = NSMutableIndexSet()
        for index in 0..<update.insertedSectionIndexes.count {
            if self.collectionView.numberOfSections() <= index {
                sectionsToInsert.addIndex(index)
            }
        }
        
        let sectionChanges = update.deletedSectionIndexes.count + update.insertedSectionIndexes.count + update.updatedSectionIndexes.count
        let itemChanges = update.deletedRowIndexPaths.count + update.insertedRowIndexPaths.count + update.updatedRowIndexPaths.count
        
        if sectionChanges > 0 {
            self.collectionView.performBatchUpdates({ () -> Void in
                self.collectionView.deleteSections(update.deletedSectionIndexes)
                self.collectionView.insertSections(update.insertedSectionIndexes)
                self.collectionView.reloadSections(update.updatedSectionIndexes)
                }, completion: nil)
        }
        
        // TODO - Check if historic workaround is needed.
        
        if itemChanges > 0 && sectionChanges == 0 {
            self.collectionView.performBatchUpdates({ () -> Void in
                self.collectionView.deleteItemsAtIndexPaths(update.deletedRowIndexPaths)
                self.collectionView.insertItemsAtIndexPaths(update.insertedRowIndexPaths)
                }, completion: nil)
                self.collectionView.reloadItemsAtIndexPaths(update.updatedRowIndexPaths)
        }
        
        self.controllerDidUpdateContent()
    }
    
    /// Call this method, if you want UICollectionView to be reloaded, and beforeContentUpdate: and afterContentUpdate: closures to be called.
    public func storageNeedsReloading() {
        self.controllerWillUpdateContent()
        collectionView.reloadData()
        self.controllerDidUpdateContent()
    }
    
    func controllerWillUpdateContent()
    {
        if let reaction = self.reactionOfReactionType(.ControllerWillUpdateContent)
        {
            reaction.perform()
        }
    }
    
    func controllerDidUpdateContent()
    {
        if let reaction = self.reactionOfReactionType(.ControllerDidUpdateContent)
        {
            reaction.perform()
        }
    }
}
