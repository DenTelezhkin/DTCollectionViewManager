//
//  MappingConditionsTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 23.07.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTCollectionViewManager
import DTModelStorage
import Nimble

class MappingConditionsTestCase: XCTestCase {
    
    var controller : DTCellTestCollectionController!
    
    override func setUp() {
        super.setUp()
        controller = DTCellTestCollectionController()
        let _ = controller.view
        controller.manager.startManaging(withDelegate: controller)
        controller.manager.storage = MemoryStorage()
    }
    
    func testMappingCanBeSwitchedBetweenSections() {
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .section(0)
        }
        controller.manager.registerNibless(AnotherIntCell.self) { mapping in
            mapping.condition = .section(1)
        }
        
        controller.manager.memoryStorage.addItem(1)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        let nibCell = controller.manager.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0))
        expect(nibCell is NibCell) == true
        
        let cell = controller.manager.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,1))
        
        expect(cell is AnotherIntCell).to(beTrue())
    }
    
    func testCustomMappingIsRevolvableForTheSameModel() {
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .custom({ indexPath, model in
                guard let model = model as? Int else { return false }
                return model > 2
            })
        }
        controller.manager.registerNibless(AnotherIntCell.self) { mapping in
            mapping.condition = .custom({ indexPath, model -> Bool in
                guard let model = model as? Int else { return false }
                return model <= 2
            })
        }
        
        controller.manager.memoryStorage.addItem(3)
        let cell = controller.manager.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0))
        expect(cell is NibCell) == true
        
        controller.manager.memoryStorage.addItem(1)
        let anotherCell = controller.manager.collectionView(controller.collectionView!, cellForItemAt: indexPath(1,0))
        expect(anotherCell is AnotherIntCell) == true
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
        
        let nibCell = controller.manager.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,0)) as? NibCell
        XCTAssertNil(nibCell?.customLabel)
        
        let customNibCell = controller.manager.collectionView(controller.collectionView!, cellForItemAt: indexPath(0,1)) as? NibCell
        
        XCTAssertNotNil(customNibCell?.customLabel)
    }
}
