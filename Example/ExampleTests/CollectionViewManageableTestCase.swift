//
//  CollectionViewManageableTestCase.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTCollectionViewManager
import Nimble

class CollectionViewManageableProtocolExtensionTestCase: XCTestCase {
    
    func testConfigurationAssociation()
    {
        let foo = DTTestCollectionController(nibName: nil, bundle: nil)
        foo.manager.startManagingWithDelegate(foo)
        
        expect(foo.manager) != nil
        expect(foo.manager) == foo.manager // Test if lazily instantiating using associations works correctly
    }
    
}

