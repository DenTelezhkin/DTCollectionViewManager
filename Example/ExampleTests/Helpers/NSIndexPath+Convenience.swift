//
//  NSIndexPath+Convenience.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

func indexPath(item: Int, _ section: Int) -> NSIndexPath
{
    return NSIndexPath(forItem: item, inSection: section)
}