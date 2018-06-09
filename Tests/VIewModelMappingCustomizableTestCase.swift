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

class CustomizableViewController: DTSupplementaryTestCollectionController, ViewModelMappingCustomizing {
    
    var mappingSelectableBlock : (([ViewModelMapping], Any) -> ViewModelMapping?)?
    
    func viewModelMapping(fromCandidates candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
        return mappingSelectableBlock?(candidates, model)
    }
}

class IntCell : UICollectionViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class AnotherIntCell : UICollectionViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class IntHeader: UICollectionReusableView, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class AnotherIntHeader: UICollectionReusableView, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class ViewModelMappingCustomizableTestCase: XCTestCase {
    
    var controller : CustomizableViewController!
    
    override func setUp() {
        super.setUp()
        controller = CustomizableViewController()
        let _ = controller.view
        controller.manager.storage = MemoryStorage()
        controller.manager.memoryStorage.configureForCollectionViewFlowLayoutUsage()
    }
    
    func testMappingCustomizableAllowsSelectingAnotherCellMapping() {
        controller.manager.registerNibless(IntCell.self)
        controller.manager.registerNibless(AnotherIntCell.self)
        controller.mappingSelectableBlock = { mappings, model in
            return mappings.last
        }
        
        controller.manager.memoryStorage.addItem(3)
        
        let cell = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, cellForItemAt: indexPath(0, 0))
        
        expect(cell is AnotherIntCell).to(beTrue())
    }
    
    func testMappingCustomizableAllowsSelectingAnotherHeaderMapping() {
        controller.manager.registerNiblessSupplementary(IntHeader.self, forKind: DTCollectionViewElementSectionHeader)
        controller.manager.registerNiblessSupplementary(AnotherIntHeader.self, forKind: DTCollectionViewElementSectionHeader)
        controller.mappingSelectableBlock = { mappings, model in
            return mappings.last
        }
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        expect(self.controller.manager.collectionDataSource?.collectionView(self.controller.collectionView!, viewForSupplementaryElementOfKind: DTCollectionViewElementSectionHeader, at: indexPath(0, 0))).to(beAKindOf(AnotherIntHeader.self))
    }
    
    func testMappingCustomizableAllowsSelectingAnotherFooterMapping() {
        controller.manager.registerNiblessSupplementary(IntHeader.self, forKind: DTCollectionViewElementSectionFooter)
        controller.manager.registerNiblessSupplementary(AnotherIntHeader.self, forKind: DTCollectionViewElementSectionFooter)
        controller.mappingSelectableBlock = { mappings, model in
            return mappings.last
        }
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        expect(self.controller.manager.collectionDataSource?.collectionView(self.controller.collectionView!, viewForSupplementaryElementOfKind: DTCollectionViewElementSectionFooter, at: indexPath(0, 0))).to(beAKindOf(AnotherIntHeader.self))
    }
}
