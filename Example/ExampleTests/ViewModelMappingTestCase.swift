//
//  ViewModelMappingTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 29.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTCollectionViewManager
import Nimble

class ViewModelMappingTestCase: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testComparisons() {
        let type = ViewType.Cell
        
        expect(type.supplementaryKind()).to(beNil())
    }
    
    func testSupplementaryKindEnum()
    {
        let type = ViewType.SupplementaryView(kind: "foo")
        
        expect(type.supplementaryKind()) == "foo"
    }
    
    func testComparisonsOfDifferentViewTypes()
    {
        let cellType = ViewType.Cell
        let supplementaryType = ViewType.SupplementaryView(kind: "foo")
        
        expect(cellType == supplementaryType).to(beFalse())
    }
    
    func testComparisonsOfSupplementaryKinds()
    {
        let viewModelMapping = ViewModelMapping(viewType: .Cell, viewTypeMirror: _reflect(UITableViewCell.self), modelTypeMirror: _reflect(String.self)) { (_, _) -> Void in
        }
        expect(viewModelMapping.description) != ""
    }
    
}
