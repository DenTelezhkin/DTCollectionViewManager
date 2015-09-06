//
//  SectionModel+ConvenienceGetters.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import DTModelStorage

/// Convenience getters and setters for collection view header and footer models, used in UICollectionViewFlowLayout
public extension SectionModel
{
    /// UICollectionView header model for current section
    var collectionHeaderModel : Any? {
        get {
           return self.supplementaryModelOfKind(UICollectionElementKindSectionHeader)
        }
        set {
            self.setSupplementaryModel(newValue, forKind: UICollectionElementKindSectionHeader)
        }
    }
    
    /// UICollectionView footer model for current section
    var collectionFooterModel : Any? {
        get {
            return self.supplementaryModelOfKind(UICollectionElementKindSectionFooter)
        }
        set {
            self.setSupplementaryModel(newValue, forKind: UICollectionElementKindSectionFooter)
        }
    }
}