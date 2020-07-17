//
//  MappingConditionsTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 23.07.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTCollectionViewManager

class MappingConditionsTestCase: XCTestCase {
    
    var controller : DTCellTestCollectionController!
    
    override func setUp() {
        super.setUp()
        controller = DTCellTestCollectionController()
        let _ = controller.view
    }
    
    func testMappingCanBeSwitchedBetweenSections() {
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .section(0)
        }
        controller.manager.register(AnotherIntCell.self) { mapping in
            mapping.condition = .section(1)
        }
        
        controller.manager.memoryStorage.addItem(1)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        let nibCell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0))
        XCTAssert(nibCell is NibCell)
        
        let cell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,1))
        
        XCTAssert(cell is AnotherIntCell)
    }
    
    func testCustomMappingIsRevolvableForTheSameModel() {
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .custom({ indexPath, model in
                guard let model = model as? Int else { return false }
                return model > 2
            })
        }
        controller.manager.register(AnotherIntCell.self) { mapping in
            mapping.condition = .custom({ indexPath, model -> Bool in
                guard let model = model as? Int else { return false }
                return model <= 2
            })
        }
        
        controller.manager.memoryStorage.addItem(3)
        let cell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0))
        XCTAssert(cell is NibCell)
        
        controller.manager.memoryStorage.addItem(1)
        let anotherCell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(1,0))
        XCTAssert(anotherCell is AnotherIntCell)
    }
    
    func testMappingCanBeSwitchedForNibNames() {
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .section(0)
            mapping.reuseIdentifier = "NibCell One"
        }
        controller.manager.registerNibNamed("CustomNibCell", for: NibCell.self) { mapping in
            mapping.condition = .section(1)
            mapping.reuseIdentifier = "NibCell Two"
        }
        
        controller.manager.memoryStorage.addItem(1)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        
        let nibCell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0)) as? NibCell
        XCTAssertNil(nibCell?.customLabel)
        
        let customNibCell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,1)) as? NibCell
        
        XCTAssertNotNil(customNibCell?.customLabel)
    }
}
