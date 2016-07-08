//
//  VIewModelMappingCustomizableTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 30.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTCollectionViewManager
import DTModelStorage
import Nimble

class CustomizableViewController: DTSupplementaryTestCollectionController, DTViewModelMappingCustomizable {
    
    var mappingSelectableBlock : (([ViewModelMapping], Any) -> ViewModelMapping?)?
    
    func viewModelMappingFromCandidates(candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
        return mappingSelectableBlock?(candidates, model)
    }
}

class IntCell : UICollectionViewCell, ModelTransfer {
    func updateWithModel(model: Int) {
        
    }
}

class AnotherIntCell : UICollectionViewCell, ModelTransfer {
    func updateWithModel(model: Int) {
        
    }
}

class IntHeader: UICollectionReusableView, ModelTransfer {
    func updateWithModel(model: Int) {
        
    }
}

class AnotherIntHeader: UICollectionReusableView, ModelTransfer {
    func updateWithModel(model: Int) {
        
    }
}

class ViewModelMappingCustomizableTestCase: XCTestCase {
    
    var controller : CustomizableViewController!
    
    override func setUp() {
        super.setUp()
        controller = CustomizableViewController()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.storage = MemoryStorage()
        controller.manager.memoryStorage.configureForCollectionViewFlowLayoutUsage()
    }
    
    func testMappingCustomizableAllowsSelectingAnotherCellMapping() {
        controller.manager.registerNiblessCellClass(IntCell)
        controller.manager.registerNiblessCellClass(AnotherIntCell)
        controller.mappingSelectableBlock = { mappings, model in
            return mappings.last
        }
        
        controller.manager.memoryStorage.addItem(3)
        
        let cell = controller.manager.collectionView(controller.collectionView!, cellForItemAtIndexPath: indexPath(0, 0))
        
        expect(cell is AnotherIntCell).to(beTrue())
    }
    
    func testMappingCustomizableAllowsSelectingAnotherHeaderMapping() {
        controller.manager.registerNiblessSupplementaryClass(IntHeader.self, forKind: UICollectionElementKindSectionHeader)
        controller.manager.registerNiblessSupplementaryClass(AnotherIntHeader.self, forKind: UICollectionElementKindSectionHeader)
        controller.mappingSelectableBlock = { mappings, model in
            return mappings.last
        }
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        expect(self.controller.manager.collectionView(self.controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, atIndexPath: indexPath(0, 0))).to(beAKindOf(AnotherIntHeader))
    }
    
    func testMappingCustomizableAllowsSelectingAnotherFooterMapping() {
        controller.manager.registerNiblessSupplementaryClass(IntHeader.self, forKind: UICollectionElementKindSectionFooter)
        controller.manager.registerNiblessSupplementaryClass(AnotherIntHeader.self, forKind: UICollectionElementKindSectionFooter)
        controller.mappingSelectableBlock = { mappings, model in
            return mappings.last
        }
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        expect(self.controller.manager.collectionView(self.controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionFooter, atIndexPath: indexPath(0, 0))).to(beAKindOf(AnotherIntHeader))
    }
}
