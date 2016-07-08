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

class CollectionViewFactoryTestCase: XCTestCase {
    
    var controller : DTSupplementaryTestCollectionController!
    
    override func setUp() {
        super.setUp()
        controller = DTSupplementaryTestCollectionController()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.storage = MemoryStorage()
    }
    
    func testCellForModelNilModelError() {
        let model: Int? = nil
        do {
            try controller.manager.viewFactory.cellForModel(model, atIndexPath: indexPath(0, 0))
        } catch DTCollectionViewFactoryError.NilCellModel(let indexPath) {
            expect(indexPath) == NSIndexPath(forItem: 0, inSection: 0)
        } catch {
            XCTFail()
        }
    }
    
    func testNoMappingsFound() {
        do {
            try controller.manager.viewFactory.cellForModel(1, atIndexPath: indexPath(0, 0))
        } catch DTCollectionViewFactoryError.NoCellMappings(let model) {
            expect(model as? Int) == 1
        } catch {
            XCTFail()
        }
    }
    
    func testNilHeaderFooterModel() {
        let model: Int? = nil
        do {
            try controller.manager.viewFactory.supplementaryViewOfKind("Foo", forModel: model, atIndexPath: indexPath(0, 0))
        } catch DTCollectionViewFactoryError.NilSupplementaryModel(let kind, let indexPath) {
            expect(kind) == "Foo"
            expect(indexPath) == NSIndexPath(forItem: 0, inSection: 0)
        } catch {
            XCTFail()
        }
    }
    
    func testNoSupplementaryViewMapping() {
        do {
            try controller.manager.viewFactory.supplementaryViewOfKind("Foo", forModel: "Bar", atIndexPath: indexPath(0, 0))
        } catch DTCollectionViewFactoryError.NoSupplementaryViewMapping(let kind, let model) {
            expect(kind) == "Foo"
            expect(model as? String) == "Bar"
        } catch {
            XCTFail()
        }
    }
    
}