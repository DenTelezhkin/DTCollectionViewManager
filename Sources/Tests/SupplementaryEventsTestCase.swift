//
//  SupplementaryEventsTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 31.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTCollectionViewManager

class ReactingSupplementaryCollectionController: DTSupplementaryTestCollectionController
{
    var indexPath : IndexPath?
    var model: Int?
    var text : String?
    
    func headerConfiguration(_ header: ReactingHeaderFooterView, model: String, sectionIndex: Int) {
        header.model = "Foo"
        header.sectionIndex = sectionIndex
    }
    
    func footerConfiguration(_ footer: ReactingHeaderFooterView, model: String, sectionIndex: Int) {
        footer.model = "Bar"
        footer.sectionIndex = sectionIndex
    }
    
    func supplementaryConfiguration(_ supplementary: ReactingHeaderFooterView, model: String, sectionIndex: Int) {
        supplementary.model = "FooBar"
        supplementary.sectionIndex = sectionIndex
    }
}

class SupplementaryEventsTestCase: XCTestCase {
    
    var controller: ReactingSupplementaryCollectionController!
    
    override func setUp() {
        super.setUp()
        controller = ReactingSupplementaryCollectionController()
        let _ = controller.view
        controller.manager.memoryStorage.configureForCollectionViewFlowLayoutUsage()
    }
    
    func testHeaderMappingFromHeaderFooterView()
    {
        controller.manager.registerHeader(ReactingHeaderFooterView.self, handler: { header, kind, indexPath in
            header.configureModel = "FooBar"
        })
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels(["1"])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 0))
        
        XCTAssertEqual((view as? ReactingHeaderFooterView)?.configureModel, "FooBar")
        XCTAssertEqual((view as? ReactingHeaderFooterView)?.model, "1")
    }
    
    func testFooterMappingFromHeaderFooterView()
    {
        controller.manager.registerFooter(ReactingHeaderFooterView.self, handler: { header, kind, indexPath in
            header.configureModel = "FooBar"
        })
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)

        controller.manager.memoryStorage.setSectionFooterModels(["1"])
        controller.manager.memoryStorage.setItems([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at:  indexPath(0, 0))
        
        XCTAssertEqual((view as? ReactingHeaderFooterView)?.configureModel, "FooBar")
        XCTAssertEqual((view as? ReactingHeaderFooterView)?.model, "1")
    }
}
