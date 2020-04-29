//
//  CollectionViewFactoryTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 30.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTCollectionViewManager

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
    }
    
    func testUpdateCellAtIndexPath() {
        controller.manager.registerNibless(UpdatableCell.self)
        let model = UpdatableModel()
        controller.manager.memoryStorage.addItem(model)
        
        controller.manager.collectionViewUpdater = controller.manager.coreDataUpdater()
        model.value = true
        controller.manager.updateCellClosure()(indexPath(0, 0),model)
        XCTAssert((controller.collectionView?.cellForItem(at: indexPath(0, 0)) as? UpdatableCell)?.model?.value ?? false)
    }

}
