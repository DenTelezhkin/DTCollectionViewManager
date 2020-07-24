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
    func register<T:ModelTransfer>(_ cellClass:T.Type, mappingBlock: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T: UICollectionViewCell
    {

    }
    
    @available(*, unavailable, renamed: "registerSupplementary(_:ofKind:handler:mapping:)")
    func registerSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T:UICollectionReusableView
    {
    }
    
    @available(*, unavailable, renamed: "registerHeader(_:handler:mapping:)")
    func registerHeader<T:ModelTransfer>(_ headerClass : T.Type, mappingBlock: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T: UICollectionReusableView {
        
    }
    
    @available(*, unavailable, renamed: "registerFooter(_:handler:mapping:)")
    func registerFooter<T:ModelTransfer>(_ footerClass: T.Type,
                                              mappingBlock: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T:UICollectionReusableView {
        
    }
}

extension DTCollectionViewManager {
    /// Registers mapping from model class to `cellClass`.
    ///
    /// Method will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class. If not - it is assumed that cell is registered in storyboard.
    /// - Note: If you need to create cell interface from code, use `registerNibless(_:)` method
    open func register<T:ModelTransfer>(_ cellClass:T.Type, handler: @escaping (T, IndexPath, T.ModelType) -> Void = { _, _, _ in }, mapping: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T: UICollectionViewCell
    {
        viewFactory.registerCellClass(T.self, handler: handler, mapping: mapping)
    }
    
    open func register<T: UICollectionViewCell, U>(_ cellClass: T.Type, for modelType: U.Type, handler: @escaping (T, IndexPath, U) -> Void, mapping: ((ViewModelMapping<T, U>) -> Void)? = nil) {
        viewFactory.registerCellClass(cellClass, modelType, handler: handler, mapping: mapping)
    }
    
    /// Registers mapping from model class to suppplementary view of `headerClass` type for UICollectionElementKindSectionHeader.
    ///
    /// Method will automatically check for nib with the same name as `headerClass`. If it exists - nib will be registered instead of class.
    open func registerHeader<T:ModelTransfer>(_ headerClass : T.Type,
                                              handler: @escaping (T, String, IndexPath) -> Void = { _, _, _ in },
                                              mapping: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T: UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self,
                                               ofKind: UICollectionView.elementKindSectionHeader,
                                               handler: handler,
                                               mapping: mapping)
    }
    
    open func registerHeader<T:UICollectionReusableView, U>(_ headerClass: T.Type, for modelType: U.Type, handler: @escaping (T, String, IndexPath) -> Void = { _, _, _ in }, mapping: ((ViewModelMapping<T, U>) -> Void)? = nil) {
        viewFactory.registerSupplementaryClass(headerClass, modelType, ofKind: UICollectionView.elementKindSectionHeader, handler: handler, mapping: mapping)
    }
    
    /// Registers mapping from model class to suppplementary view of `footerClass` type for UICollectionElementKindSectionFooter.
    ///
    /// Method will automatically check for nib with the same name as `footerClass`. If it exists - nib will be registered instead of class.
    open func registerFooter<T:ModelTransfer>(_ footerClass: T.Type,
                                              handler: @escaping (T, String, IndexPath) -> Void = { _, _, _ in },
                                              mapping: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self,
                                               ofKind: UICollectionView.elementKindSectionFooter,
                                               handler: handler,
                                               mapping: mapping)
    }
    
    open func registerFooter<T:UICollectionReusableView, U>(_ footerClass: T.Type, for modelType: U.Type, handler: @escaping (T, String, IndexPath) -> Void = { _, _, _ in }, mapping: ((ViewModelMapping<T, U>) -> Void)? = nil) {
        viewFactory.registerSupplementaryClass(footerClass, modelType, ofKind: UICollectionView.elementKindSectionFooter, handler: handler, mapping: mapping)
    }
    
    /// Registers mapping from model class to suppplementary view of `supplementaryClass` type for supplementary `kind`.
    ///
    /// Method will automatically check for nib with the same name as `supplementaryClass`. If it exists - nib will be registered instead of class.
    open func registerSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type,
                                                     ofKind kind: String,
                                                     handler: @escaping (T, String, IndexPath) -> Void = { _, _, _ in },
                                                     mapping: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(T.self, ofKind: kind, handler: handler, mapping: mapping)
    }
    
    open func registerSupplementary<T:UICollectionReusableView, U>(_ supplementaryClass: T.Type, ofKind kind: String, for modelType: U.Type, handler: @escaping (T, String, IndexPath) -> Void = { _, _, _ in }, mapping: ((ViewModelMapping<T, U>) -> Void)? = nil) {
        viewFactory.registerSupplementaryClass(supplementaryClass, modelType, ofKind: kind, handler: handler, mapping: mapping)
    }
    
    /// Unregisters `cellClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregister<T:ModelTransfer>(_ cellClass: T.Type) where T: UICollectionViewCell {
        viewFactory.unregisterCellClass(T.self)
    }
    
    /// Unregisters `headerClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterHeader<T:ModelTransfer>(_ headerClass: T.Type) where T:UICollectionReusableView {
        unregisterSupplementary(T.self, ofKind: UICollectionView.elementKindSectionHeader)
    }
    
    /// Unregisters `footerClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterFooter<T:ModelTransfer>(_ headerClass: T.Type) where T:UICollectionReusableView {
        unregisterSupplementary(T.self, ofKind: UICollectionView.elementKindSectionFooter)
    }
    
    /// Unregisters `supplementaryClass` of `kind` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, ofKind kind: String) where T:UICollectionReusableView {
        viewFactory.unregisterSupplementaryClass(T.self, ofKind: kind)
    }
}
