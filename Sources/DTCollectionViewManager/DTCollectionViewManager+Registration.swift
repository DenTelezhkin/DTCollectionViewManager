//
//  DTCollectionViewManager+Registration.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 27.08.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
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

import UIKit
import DTModelStorage

// Upgrade shims for easier API upgrading
public extension DTCollectionViewManager {
    @available(*, unavailable, renamed: "register(_:handler:mapping:)")
    func register<T:ModelTransfer>(_ cellClass:T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionViewCell
    {

    }
    @available(*, unavailable, renamed: "register(_:handler:mapping:)")
    func registerNibless<T:ModelTransfer>(_ cellClass:T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionViewCell
    {
        viewFactory.registerCellClass(T.self, handler: { _, _, _ in }, mapping: { mappingInstance in
            mappingInstance.xibName = nil
            mappingBlock?(mappingInstance)
        })
    }
    
    @available(*, unavailable, renamed: "registerSupplementary(_:handler:mapping:)")
    func registerSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
    }
    
    @available(*, unavailable, renamed: "registerHeader(_:handler:mapping:)")
    func registerHeader<T:ModelTransfer>(_ headerClass : T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionReusableView {
        
    }
    
    @available(*, unavailable, renamed: "registerFooter(_:handler:mapping:)")
    func registerFooter<T:ModelTransfer>(_ footerClass: T.Type,
                                              mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
        
    }
    
    @available(*, unavailable, renamed: "registerSupplementary(_:kind:handler:mapping:)")
    /// Registers mapping from model class to supplementary view of `supplementaryClass` type for supplementary `kind`.
    func registerNiblessSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
    }
    
    @available(*, unavailable, renamed: "registerHeader(_:handler:mapping:)")
    /// Registers mapping from model class to header view of `headerClass` type for `UICollectionElementKindSectionHeader`.
    func registerNiblessHeader<T:ModelTransfer>(_ headerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
    }
    
    @available(*, unavailable, renamed: "registerFooter(_:handler:mapping:)")
    /// Registers mapping from model class to footer view of `footerClass` type for `UICollectionElementKindSectionFooter`.
    func registerNiblessFooter<T:ModelTransfer>(_ footerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView {
    }
}

// Deprecated methods
extension DTCollectionViewManager {
    /// Registers mapping from model class to supplementary view of `supplementaryClass` type with `nibName` for supplementary `kind`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forSupplementary supplementaryClass: T.Type, ofKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        registerSupplementary(T.self, forKind: kind,
                              handler: { _, _, _ in },
                              mapping: { mappingInstance in
            mappingInstance.xibName = nibName
            mappingBlock?(mappingInstance)
        })
    }
    
    /// Registers mapping from model class to supplementary view of `headerClass` type with `nibName` for UICollectionElementKindSectionHeader.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forHeader headerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        registerSupplementary(T.self,
                              forKind: UICollectionView.elementKindSectionHeader,
                              handler: { _, _, _ in },
                              mapping: { mappingInstance in
            mappingInstance.xibName = nibName
            mappingBlock?(mappingInstance)
        })
    }
    
    /// Registers mapping from model class to supplementary view of `footerClass` type with `nibName` for UICollectionElementKindSectionFooter.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, forFooter footerClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        registerSupplementary(T.self,
                              forKind: UICollectionView.elementKindSectionFooter,
                              handler: { _, _, _ in },
                              mapping: { mappingInstance in
            mappingInstance.xibName = nibName
            mappingBlock?(mappingInstance)
        })
    }
}

extension DTCollectionViewManager {
    /// Registers mapping from model class to `cellClass`.
    ///
    /// Method will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class. If not - it is assumed that cell is registered in storyboard.
    /// - Note: If you need to create cell interface from code, use `registerNibless(_:)` method
    open func register<T:ModelTransfer>(_ cellClass:T.Type, handler: @escaping (T, IndexPath, T.ModelType) -> Void = { _, _, _ in }, mapping: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionViewCell
    {
        viewFactory.registerCellClass(T.self, handler: handler, mapping: mapping)
    }
    
    open func register<T: UICollectionViewCell, U>(_ cellType: T.Type, _ modelType: U.Type, handler: @escaping (T, IndexPath, U) -> Void, mapping: ((ViewModelMapping) -> Void)? = nil) {
        viewFactory.registerCellClass(cellType, modelType, handler: handler, mapping: mapping)
    }
    
    /// Registers nib with `nibName` mapping from model class to `cellClass`.
    open func registerNibNamed<T:ModelTransfer>(_ nibName: String, for cellClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionViewCell
    {
        register(T.self, mapping: { mapping in
            mapping.xibName = nibName
        })
    }
    
    /// Registers mapping from model class to suppplementary view of `headerClass` type for UICollectionElementKindSectionHeader.
    ///
    /// Method will automatically check for nib with the same name as `headerClass`. If it exists - nib will be registered instead of class.
    open func registerHeader<T:ModelTransfer>(_ headerClass : T.Type,
                                              handler: @escaping (T, String, IndexPath) -> Void = { _, _, _ in },
                                              mapping: ((ViewModelMapping) -> Void)? = nil) where T: UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self,
                                               forKind: UICollectionView.elementKindSectionHeader,
                                               handler: handler,
                                               mapping: mapping)
    }
    
    /// Registers mapping from model class to suppplementary view of `footerClass` type for UICollectionElementKindSectionFooter.
    ///
    /// Method will automatically check for nib with the same name as `footerClass`. If it exists - nib will be registered instead of class.
    open func registerFooter<T:ModelTransfer>(_ footerClass: T.Type,
                                              handler: @escaping (T, String, IndexPath) -> Void = { _, _, _ in },
                                              mapping: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self,
                                               forKind: UICollectionView.elementKindSectionFooter,
                                               handler: handler,
                                               mapping: mapping)
    }
    
    /// Registers mapping from model class to suppplementary view of `supplementaryClass` type for supplementary `kind`.
    ///
    /// Method will automatically check for nib with the same name as `supplementaryClass`. If it exists - nib will be registered instead of class.
    open func registerSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type,
                                                     forKind kind: String,
                                                     handler: @escaping (T, String, IndexPath) -> Void = { _, _, _ in },
                                                     mapping: ((ViewModelMapping) -> Void)? = nil) where T:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self, forKind: kind, handler: handler, mapping: mapping)
    }
    
    /// Unregisters `cellClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregister<T:ModelTransfer>(_ cellClass: T.Type) where T: UICollectionViewCell {
        viewFactory.unregisterCellClass(T.self)
    }
    
    /// Unregisters `headerClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterHeader<T:ModelTransfer>(_ headerClass: T.Type) where T:UICollectionReusableView {
        unregisterSupplementary(T.self, forKind: UICollectionView.elementKindSectionHeader)
    }
    
    /// Unregisters `footerClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterFooter<T:ModelTransfer>(_ headerClass: T.Type) where T:UICollectionReusableView {
        unregisterSupplementary(T.self, forKind: UICollectionView.elementKindSectionFooter)
    }
    
    /// Unregisters `supplementaryClass` of `kind` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String) where T:UICollectionReusableView {
        viewFactory.unregisterSupplementaryClass(T.self, forKind: kind)
    }
}
