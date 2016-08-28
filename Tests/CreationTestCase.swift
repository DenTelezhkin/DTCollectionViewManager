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
import Nimble

class FooCell : UICollectionViewCell, ModelTransfer
{
    func updateWithModel(_ model: Int) {
        
    }
}

class CreationTestCase: XCTestCase {
    
    func testDelegateIsNotNil() {
        let controller = DTCellTestCollectionController()
        controller.manager.startManagingWithDelegate(controller)
        expect(controller.manager.storage.delegate != nil).to(beTrue())
    }
    
    func testDelegateIsNotNilForMemoryStorage() {
        let controller = DTCellTestCollectionController()
        controller.manager.startManagingWithDelegate(controller)
        expect(controller.manager.memoryStorage.delegate != nil).to(beTrue())
    }
    
    func testSwitchingStorages() {
        let controller = DTCellTestCollectionController()
        let first = MemoryStorage()
        let second = MemoryStorage()
        controller.manager.storage = first
        expect(first.delegate === controller.manager).to(beTrue())
        
        controller.manager.storage = second
        
        expect(first.delegate == nil).to(beTrue())
        expect(second.delegate === controller.manager).to(beTrue())
    }
    
    func testCreatingCollectionControllerFromCode()
    {
        let controller = DTCellTestCollectionController()
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.registerCellClass(FooCell.self)
    }
    
    func testCreatingCollectionControllerFromXIB()
    {
        let controller = XibCollectionViewController(nibName: "XibCollectionViewController", bundle: Bundle(for: type(of: self)))
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.registerCellClass(FooCell.self)
    }
    
    func testConfigurationAssociation()
    {
        let foo = DTCellTestCollectionController(nibName: nil, bundle: nil)
        foo.manager.startManagingWithDelegate(foo)
        
        expect(foo.manager) != nil
        expect(foo.manager) == foo.manager // Test if lazily instantiating using associations works correctly
    }
    
    func testManagerSetter()
    {
        let manager = DTCollectionViewManager()
        let foo = DTCellTestCollectionController(nibName: nil, bundle: nil)
        foo.manager = manager
        foo.manager.startManagingWithDelegate(foo)
        
        expect(foo.manager === manager).to(beTruthy())
    }
}
