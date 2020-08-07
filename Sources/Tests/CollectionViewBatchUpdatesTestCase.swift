//
//  CollectionViewBatchUpdatesTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 02.12.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import XCTest
import XCTest
import DTCollectionViewManager

// This unit test shows problem, described in https://github.com/DenTelezhkin/DTCollectionViewManager/issues/23 and https://github.com/DenTelezhkin/DTCollectionViewManager/issues/27

private class Cell: UICollectionViewCell, ModelTransfer {
    func update(with model: Model) { }
}

private class Model { }

class CollectionViewCrashTest: XCTestCase, DTCollectionViewManageable {
    var collectionView: UICollectionView!
    
    override func setUp() {
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: UICollectionViewFlowLayout())
        manager.register(Cell.self)
    }
    
    func testThisShouldNotCrash() {
        manager.memoryStorage.setItems([Model(), Model()])
        manager.memoryStorage.addItems([Model(), Model(), Model()])

        XCTAssertEqual(manager.memoryStorage.totalNumberOfItems, 5)
    }
    
    func testSettingAndAddingItemsWithDeferredDatasourceUpdatesWorks() {
        manager.memoryStorage.setItems([Model(), Model()])
        manager.memoryStorage.addItems([Model(), Model(), Model()])
        
        XCTAssertEqual(manager.memoryStorage.totalNumberOfItems, 5)
    }
}
