//
//  MappingTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import Nimble
import DTModelStorage
@testable import DTCollectionViewManager

class MappingTestCase: XCTestCase {
    
    var controller = DTCellTestCollectionController()
    
    override func setUp() {
        super.setUp()
        let _ = controller.view
    }
    
    func testRegistrationWithDifferentNibName()
    {
        controller.manager.registerNibNamed("RandomNibNameCell", for: NibCell.self)
        
        controller.manager.memoryStorage.addItem(3)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0,0))) == true
    }
    
    func testOptionalUnwrapping()
    {
        controller.manager.register(NibCell.self)
        
        let intOptional : Int? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testSeveralLevelsOfOptionalUnwrapping()
    {
        controller.manager.register(NibCell.self)
        
        let intOptional : Int?? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testNiblessMapping()
    {
        controller.manager.registerNibless(StringCell.self)
        controller.manager.memoryStorage.addItem("foo")
        
        expect(self.controller.manager.memoryStorage.item(at: indexPath(0, 0)) as? String) == "foo"
    }
    
    func testUnregisterCellClass() {
        controller.manager.register(NibCell.self)
        controller.manager.unregister(NibCell.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 0
    }
    
    func testUnregisterHeaderClass() {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibHeaderFooterView.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 0
    }
    
    func testUnregisterFooterClass() {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.unregisterFooter(NibHeaderFooterView.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 0
    }
    
    func testUnregisterHeaderClassDoesNotUnregisterCell() {
        controller.manager.register(NibCell.self)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibCell.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 2
    }
    
    func testUnregisteringHeaderDoesNotUnregisterFooter() {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibHeaderFooterView.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 1
    }

}

class NibNameViewModelMappingTestCase : XCTestCase {
    var factory : CollectionViewFactory!
    
    override func setUp() {
        super.setUp()
        factory = CollectionViewFactory(collectionView: UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout()))
    }
    
    func testRegisterCellWithoutNibYieldsNoXibName() {
        factory.registerCellClass(NiblessCell.self, mappingBlock: nil)
        
        expect(self.factory.mappings.first?.xibName).to(beNil())
    }
    
    func testCellWithXibHasXibNameInMapping() {
        factory.registerCellClass(NibCell.self, mappingBlock: nil)
        
        expect(self.factory.mappings.first?.xibName) == "NibCell"
    }
    
    func testHeaderHasXibInMapping() {
        factory.registerSupplementaryClass(NibHeaderFooterView.self, forKind: UICollectionElementKindSectionHeader, mappingBlock: nil)
        
        expect(self.factory.mappings.first?.xibName) == "NibHeaderFooterView"
    }
    
    func testFooterHasXibInMapping() {
        factory.registerSupplementaryClass(NibHeaderFooterView.self, forKind: UICollectionElementKindSectionFooter, mappingBlock: nil)
        
        expect(self.factory.mappings.first?.xibName) == "NibHeaderFooterView"
    }
}
