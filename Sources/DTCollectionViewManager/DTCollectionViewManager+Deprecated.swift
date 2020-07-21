//
//  DTCollectionViewManager+Deprecated.swift
//
//  Created by Denys Telezhkin on 22.07.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
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

/// Deprecated methods
public extension DTCollectionViewManager {
    @available(*, deprecated, message: "Please use handler parameter in register(_:handler:mapping:) method instead.")
    /// Registers `closure` to be executed, when `UICollectionView` requests `cellClass` in `UICollectionViewDataSource.collectionView(_:cellForItemAt:)` method and cell is being configured.
    ///
    /// This closure will be performed *after* cell is created and `update(with:)` method is called.
    func configure<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionViewCell
    {
        collectionDataSource?.appendReaction(for: T.self, signature: .configureCell, closure: closure)
    }
    
    @available(*, deprecated, message: "Please use handler parameter in registerHeader(_:handler:mapping:) method instead.")
    /// Registers `closure` to be executed, when `UICollectionView` requests `headerClass` in `UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOf:at:)` method and header is being configured.
    ///
    /// This closure will be performed *after* header is created and `update(with:)` method is called.
    func configureHeader<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UICollectionReusableView
    {
        let indexPathClosure : (T, T.ModelType, IndexPath) -> Void = { view, model, indexPath in
            closure(view, model, indexPath.section)
        }
        configureSupplementary(T.self, ofKind: UICollectionView.elementKindSectionHeader, indexPathClosure)
    }
    
    @available(*, deprecated, message: "Please use handler parameter in registerFooter(_:handler:mapping:) method instead.")
    /// Registers `closure` to be executed, when `UICollectionView` requests `footerClass` in `UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOf:at:)` method and footer is being configured.
    ///
    /// This closure will be performed *after* footer is created and `update(with:)` method is called.
    func configureFooter<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UICollectionReusableView
    {
        let indexPathClosure : (T, T.ModelType, IndexPath) -> Void = { view, model, indexPath in
            closure(view, model, indexPath.section)
        }
        configureSupplementary(T.self, ofKind: UICollectionView.elementKindSectionFooter, indexPathClosure)
    }
    
    @available(*, deprecated, message: "Please use handler parameter in registerSupplementary(_:ofKind:handler:mapping:) method instead.")
    /// Registers `closure` to be executed, when `UICollectionView` requests `supplementaryClass` of `kind` in `UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOf:at:)` method and supplementary view is being configured.
    ///
    /// This closure will be performed *after* supplementary view is created and `update(with:)` method is called.
    func configureSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, ofKind kind: String, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UICollectionReusableView
    {
        collectionDataSource?.appendReaction(forSupplementaryKind: kind, supplementaryClass: T.self, signature: .configureSupplementary, closure: closure)
    }
    
    @available(*, deprecated, message: "Please use registerSupplementary(_:kind:handler:mapping:) instead.")
    /// Registers mapping from model class to supplementary view of `supplementaryClass` type for supplementary `kind`.
    func registerNiblessSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
        viewFactory.registerSupplementaryClass(T.self, ofKind: kind, handler: { _, _, _ in }, mapping: { mapping in
            mapping.xibName = nil
            mappingBlock?(mapping)
        })
    }
    @available(*, deprecated, message: "Please use registerHeader(_:handler:mapping:) instead.")
    /// Registers mapping from model class to header view of `headerClass` type for `UICollectionElementKindSectionHeader`.
    func registerNiblessHeader<T:ModelTransfer>(_ headerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
        registerHeader(T.self, handler: { _, _, _ in }, mapping: { mapping in
            mapping.xibName = nil
            mappingBlock?(mapping)
        })
    }
    
    @available(*, deprecated, message: "Please use registerFooter(_:handler:mapping:) instead")
    /// Registers mapping from model class to footer view of `footerClass` type for `UICollectionElementKindSectionFooter`.
    func registerNiblessFooter<T:ModelTransfer>(_ footerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
        registerFooter(T.self, handler: { _, _, _ in }, mapping: { mapping in
            mapping.xibName = nil
            mappingBlock?(mapping)
        })
    }
    @available(*, deprecated, message: "Please use register(_:handler:mapping:) instead.")
    func registerNibless<T:ModelTransfer>(_ cellClass:T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionViewCell
    {
        viewFactory.registerCellClass(T.self, handler: { _, _, _ in }, mapping: { mappingInstance in
            mappingInstance.xibName = nil
            mappingBlock?(mappingInstance)
        })
    }
    
    @available(*, deprecated, message: "Please use registerSupplementary(_:kind:handler:mapping:) and set xibName in mapping closure instead.")
    /// Registers mapping from model class to supplementary view of `supplementaryClass` type with `nibName` for supplementary `kind`.
    func registerNibNamed<T:ModelTransfer>(_ nibName: String, forSupplementary supplementaryClass: T.Type, ofKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        registerSupplementary(T.self, ofKind: kind,
                              handler: { _, _, _ in },
                              mapping: { mappingInstance in
            mappingInstance.xibName = nibName
            mappingBlock?(mappingInstance)
        })
    }
    
    @available(*, deprecated, message: "Please use registerHeader(_:handler:mapping:) and set xibName in mapping closure instead.")
    /// Registers mapping from model class to supplementary view of `headerClass` type with `nibName` for UICollectionElementKindSectionHeader.
    func registerNibNamed<T:ModelTransfer>(_ nibName: String, forHeader headerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        registerSupplementary(T.self,
                              ofKind: UICollectionView.elementKindSectionHeader,
                              handler: { _, _, _ in },
                              mapping: { mappingInstance in
            mappingInstance.xibName = nibName
            mappingBlock?(mappingInstance)
        })
    }
    
    @available(*, deprecated, message: "Please use registerFooter(_:handler:mapping:) and set xibName in mapping closure instead.")
    /// Registers mapping from model class to supplementary view of `footerClass` type with `nibName` for UICollectionElementKindSectionFooter.
    func registerNibNamed<T:ModelTransfer>(_ nibName: String, forFooter footerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        registerSupplementary(T.self,
                              ofKind: UICollectionView.elementKindSectionFooter,
                              handler: { _, _, _ in },
                              mapping: { mappingInstance in
            mappingInstance.xibName = nibName
            mappingBlock?(mappingInstance)
        })
    }
    
    @available(*, deprecated, message: "Please use register(_:handler:mapping:) and set xibName in mapping closure instead.")
    /// Registers nib with `nibName` mapping from model class to `cellClass`.
    func registerNibNamed<T:ModelTransfer>(_ nibName: String, for cellClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionViewCell
    {
        register(T.self, mapping: { mapping in
            mapping.xibName = nibName
        })
    }
}
