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
    func updateWithModel(model: Int) {
        
    }
}

class CreationTestCase: XCTestCase {
    
    func testCreatingCollectionControllerFromCode()
    {
        let controller = DTTestCollectionController()
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.registerCellClass(FooCell)
    }
    
    func testCreatingCollectionControllerFromXIB()
    {
        let controller = XibCollectionViewController(nibName: "XibCollectionViewController", bundle: NSBundle(forClass: self.dynamicType))
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.registerCellClass(FooCell)
    }
}
