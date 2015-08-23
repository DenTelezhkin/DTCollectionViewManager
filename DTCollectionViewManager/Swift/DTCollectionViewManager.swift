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
    /// Lazily instantiated `DTTableViewManager` instance. When your table view is loaded, call startManagingWithDelegate: method and `DTTableViewManager` will take over UITableView datasource and delegate. Any method, that is not implemented by `DTTableViewManager`, will be forwarded to delegate.
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
}