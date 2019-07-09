//
//  CreationTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTCollectionViewManager
import DTModelStorage

class FooCell : UICollectionViewCell, ModelTransfer
{
    func update(with model: Int) {
        
    }
}

class OptionalCollectionViewController : UIViewController, DTCollectionViewManageable {
    var optionalCollectionView: UICollectionView?
}

class CreationTestCase: XCTestCase {
    
    func testManagingWithOptionalCollectionViewWorks() {
        let controller = OptionalCollectionViewController()
        controller.optionalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        XCTAssertTrue(controller.manager.isManagingCollectionView)
    }
    
    func testDelegateIsNotNil() {
        let controller = DTCellTestCollectionController()
        XCTAssertNotNil(controller.manager.storage.delegate)
    }
    
    func testDelegateIsNotNilForMemoryStorage() {
        let controller = DTCellTestCollectionController()
        XCTAssertNotNil(controller.manager.storage.delegate)
    }
    
    func testSwitchingStorages() {
        let controller = DTCellTestCollectionController()
        let first = MemoryStorage()
        let second = MemoryStorage()
        controller.manager.storage = first
        XCTAssert(first.delegate === controller.manager.collectionViewUpdater)
        
        controller.manager.storage = second
        
        XCTAssertNil(first.delegate)
        XCTAssert(second.delegate === controller.manager.collectionViewUpdater)
    }
    
    func testCreatingCollectionControllerFromCode()
    {
        let controller = DTCellTestCollectionController()
        controller.manager.register(FooCell.self)
    }
    
    func testCreatingCollectionControllerFromXIB()
    {
        let controller = XibCollectionViewController(nibName: "XibCollectionViewController", bundle: Bundle(for: type(of: self)))
        controller.manager.register(FooCell.self)
    }
    
    func testConfigurationAssociation()
    {
        let foo = DTCellTestCollectionController(nibName: nil, bundle: nil)
        
        XCTAssertNotNil(foo.manager)
        XCTAssert(foo.manager === foo.manager) // Test if lazily instantiating using associations works correctly
    }
    
    func testManagerSetter()
    {
        let manager = DTCollectionViewManager()
        let foo = DTCellTestCollectionController(nibName: nil, bundle: nil)
        foo.manager = manager
        XCTAssert(foo.manager === manager)
    }
    
    func testStartManagingWithDelegateIsNotRequired() {
        let controller = DTCellTestCollectionController()
        controller.manager.register(FooCell.self)
    }
}
