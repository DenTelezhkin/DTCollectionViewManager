//
//  CollectionViewManager+UnitTests.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import DTCollectionViewManager
import UIKit

protocol ModelRetrievable
{
    var model : Any! { get }
}

func recursiveForceUnwrap<T>(any: T) -> T
{
    let mirror = _reflect(any)
    if mirror.disposition != .Optional
    {
        return any
    }
    let (_,some) = mirror[0]
    return recursiveForceUnwrap(some.value as! T)
}

extension DTCellTestCollectionController
{
    func verifyItem<T:Equatable>(item: T, atIndexPath indexPath: NSIndexPath) -> Bool
    {
        let itemTable = (self.manager.collectionView(self.collectionView!, cellForItemAtIndexPath: indexPath) as! ModelRetrievable).model as! T
        let itemDatasource = recursiveForceUnwrap(self.manager.storage.itemAtIndexPath(indexPath)!) as! T
        
        if !(item == itemDatasource)
        {
            return false
        }
        
        if !(item == itemTable)
        {
            return false
        }
        
        return true
    }
    
    func verifySection(section: [Int], withSectionNumber sectionNumber: Int) -> Bool
    {
        for itemNumber in 0..<section.count
        {
            if !(self.verifyItem(section[itemNumber], atIndexPath: NSIndexPath(forItem: itemNumber, inSection: sectionNumber)))
            {
                return false
            }
        }
        if self.manager.collectionView(self.collectionView!, numberOfItemsInSection: sectionNumber) == section.count
        {
            return true
        }
        return false
    }
}