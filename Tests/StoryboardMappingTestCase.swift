//
//  StoryboardMappingTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 10.01.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import XCTest
import Nimble
import DTModelStorage
@testable import DTCollectionViewManager

class StoryboardMappingTestCase: XCTestCase {
    
    var controller : StoryboardViewController!
    
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "FixtureStoryboard", bundle: NSBundle(forClass: self.dynamicType))
        controller = storyboard.instantiateInitialViewController() as! StoryboardViewController
        _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
    }
    
    func testStoryboardCellIsCreatedAndOutletsAreWired() {
        controller.manager.registerCellClass(StoryboardCollectionViewCell)
        controller.manager.memoryStorage.addItem(3)
        
        let cell = controller.manager.collectionView(controller.collectionView!, cellForItemAtIndexPath: indexPath(0, 0)) as? StoryboardCollectionViewCell
        
        expect(cell?.storyboardLabel).toNot(beNil())
    }
    
    func testSupplementaryHeadersAreRegisteredAndOutletsAreWired() {
        controller.manager.registerHeaderClass(StoryboardCollectionReusableHeaderView)
        controller.manager.registerFooterClass(StoryboardCollectionReusableFooterView)
        
        
        controller.manager.memoryStorage.setSectionHeaderModels(["1"])
        controller.manager.memoryStorage.setSectionFooterModels(["2"])
        
        if #available(iOS 9, *) {
            controller.collectionView?.performBatchUpdates(nil, completion: nil)
            
            let headerView = controller.manager.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, atIndexPath:  indexPath(0, 0)) as? StoryboardCollectionReusableHeaderView
            
            let footerView = controller.manager.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionElementKindSectionFooter, atIndexPath:  indexPath(0, 0)) as? StoryboardCollectionReusableFooterView
            
            expect(headerView?.storyboardLabel.text) == "Header"
            expect(footerView?.storyboardLabel.text) == "Footer"
        }
        
    }
}
