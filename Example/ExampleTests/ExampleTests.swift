//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import Nimble
import DTCollectionViewManager


class ExampleTests: XCTestCase {
    
    
    func testExample() {
        let _ = MemoryStorage()
        
        expect(3) == (2+1)
    }
    
    
}
