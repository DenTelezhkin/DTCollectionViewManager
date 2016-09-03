//
//  CollectionViewFactoryTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 30.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTCollectionViewManager
import DTModelStorage
import Nimble

fileprivate class UpdatableModel {
    var value: Bool = false
}

fileprivate class UpdatableCell : UICollectionViewCell, ModelTransfer {
    var model : UpdatableModel?
    
    func update(with model: UpdatableModel) {
        self.model = model
    }
    
    fileprivate override func prepareForReuse() {
        super.prepareForReuse()
        XCTFail()
    }
}

class CollectionViewFactoryTestCase: XCTestCase {
    
    var controller : DTSupplementaryTestCollectionController!
    
    override func setUp() {
        super.setUp()
        controller = DTSupplementaryTestCollectionController()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.storage = MemoryStorage()
    }
    
    func testNoMappingsFound() {
        do {
            try _ = controller.manager.viewFactory.cellForModel(1, atIndexPath: indexPath(0, 0))
        } catch DTCollectionViewFactoryError.noCellMappings(let model) {
            expect(model as? Int) == 1
        } catch {
            XCTFail()
        }
    }
    
    func testNilHeaderFooterModel() {
        let model: Int? = nil
        do {
            try _ = controller.manager.viewFactory.supplementaryViewOfKind("Foo", forModel: model, atIndexPath: indexPath(0, 0))
        } catch DTCollectionViewFactoryError.nilSupplementaryModel(let kind, let indexPath) {
            expect(kind) == "Foo"
            expect(indexPath) == IndexPath(item: 0, section: 0)
        } catch {
            XCTFail()
        }
    }
    
    func testNoSupplementaryViewMapping() {
        do {
            try _ = controller.manager.viewFactory.supplementaryViewOfKind("Foo", forModel: "Bar", atIndexPath: indexPath(0, 0))
        } catch DTCollectionViewFactoryError.noSupplementaryViewMapping(let kind, let model) {
            expect(kind) == "Foo"
            expect(model as? String) == "Bar"
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateCellAtIndexPath() {
        controller.manager.registerNiblessCellClass(UpdatableCell.self)
        let model = UpdatableModel()
        controller.manager.memoryStorage.addItem(model)
        
        controller.manager.collectionViewUpdater = controller.manager.coreDataUpdater()
        model.value = true
        controller.manager.updateCellClosure()(indexPath(0, 0))
        expect((self.controller.collectionView?.cellForItem(at: indexPath(0, 0)) as? UpdatableCell)?.model?.value).to(beTrue())
    }

}
