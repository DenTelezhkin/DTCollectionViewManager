//
//  CollectionViewUpdater.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 03.09.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

open class CollectionViewUpdater : StorageUpdating {
    
    weak var collectionView: UICollectionView?
    public var willUpdateContent: ((StorageUpdate?) -> Void)? = nil
    public var didUpdateContent: ((StorageUpdate?) -> Void)? = nil
    
    public var reloadItemClosure : ((IndexPath) -> Void)?
    
    public var animateMoveAsDeleteAndInsert: Bool
    
    /// Boolean property, that indicates whether batch updates are completed.
    /// - Note: this can be useful if you are deciding whether to run another batch of animations - insertion, deletions etc. UICollectionView is not very tolerant to multiple performBatchUpdates, executed at once.
    public var batchUpdatesInProgress: Bool = false
    
    public init(collectionView: UICollectionView,
                reloadItem: ((IndexPath) -> Void)? = nil,
                animateMoveAsDeleteAndInsert: Bool = false) {
        self.collectionView = collectionView
        self.reloadItemClosure = reloadItem
        self.animateMoveAsDeleteAndInsert = animateMoveAsDeleteAndInsert
    }
    
    open func storageDidPerformUpdate(_ update : StorageUpdate)
    {
        willUpdateContent?(update)
        
        collectionView?.performBatchUpdates({ [weak self] in
            if update.insertedRowIndexPaths.count > 0 { self?.collectionView?.insertItems(at: Array(update.insertedRowIndexPaths)) }
            if update.deletedRowIndexPaths.count > 0 { self?.collectionView?.deleteItems(at: Array(update.deletedRowIndexPaths)) }
            if update.updatedRowIndexPaths.count > 0 {
                if let closure = self?.reloadItemClosure {
                    update.updatedRowIndexPaths.forEach(closure)
                } else {
                    self?.collectionView?.reloadItems(at: Array(update.updatedRowIndexPaths))
                }
            }
            if update.movedRowIndexPaths.count > 0 {
                for moveAction in update.movedRowIndexPaths {
                    if let from = moveAction.first, let to = moveAction.last {
                        if self?.animateMoveAsDeleteAndInsert ?? false {
                            self?.collectionView?.deleteItems(at: [from])
                            self?.collectionView?.insertItems(at: [to])
                        } else {
                            self?.collectionView?.moveItem(at: from, to: to)
                        }
                    }
                }
            }
            
            if update.insertedSectionIndexes.count > 0 { self?.collectionView?.insertSections(IndexSet(update.insertedSectionIndexes)) }
            if update.deletedSectionIndexes.count > 0 { self?.collectionView?.deleteSections(IndexSet(update.deletedSectionIndexes)) }
            if update.updatedSectionIndexes.count > 0 { self?.collectionView?.reloadSections(IndexSet(update.updatedSectionIndexes))}
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
        
        didUpdateContent?(update)
    }
    
    /// Call this method, if you want UITableView to be reloaded, and beforeContentUpdate: and afterContentUpdate: closures to be called.
    open func storageNeedsReloading()
    {
        willUpdateContent?(nil)
        collectionView?.reloadData()
        didUpdateContent?(nil)
    }
}
