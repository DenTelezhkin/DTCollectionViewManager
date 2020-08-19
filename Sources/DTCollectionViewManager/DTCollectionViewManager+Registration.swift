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

/// Upgrade shims for easier API upgrading
public extension DTCollectionViewManager {
    @available(*, unavailable, renamed: "register(_:handler:mapping:)")
    /// This method is unavailable, please use `register(_:handler:mapping:)` as a replacement.
    func register<T:ModelTransfer>(_ cellClass:T.Type, mappingBlock: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T: UICollectionViewCell
    {
    }
    
    @available(*, unavailable, renamed: "registerSupplementary(_:ofKind:handler:mapping:)")
    /// This method is unavailable, please use `registerSupplementary(_:handler:mapping:)` as a replacement.
    func registerSupplementary<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T:UICollectionReusableView
    {
    }
    
    @available(*, unavailable, renamed: "registerHeader(_:handler:mapping:)")
    /// This method is unavailable, please use `registerHeader(_:handler:mapping:)` as a replacement.
    func registerHeader<T:ModelTransfer>(_ headerClass : T.Type, mappingBlock: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T: UICollectionReusableView {
        
    }
    
    @available(*, unavailable, renamed: "registerFooter(_:handler:mapping:)")
    /// This method is unavailable, please use `registerFooter(_:handler:mapping:)` as a replacement.
    func registerFooter<T:ModelTransfer>(_ footerClass: T.Type,
                                              mappingBlock: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T:UICollectionReusableView {
        
    }
}

extension DTCollectionViewManager {
    /// Registers mapping for `cellClass`. Mapping will automatically check for nib with the same name as `cellClass` and register it, if it is found. If cell is designed in storyboard, please set `mapping.cellRegisteredByStoryboard` property to `true` inside of `mapping` closure.
    /// - Parameters:
    ///   - cellClass: UICollectionViewCell subclass type, conforming to `ModelTransfer` protocol.
    ///   - handler: configuration closure, that is run when cell is dequeued.
    ///   - mapping: mapping configuration closure, executed before any registration or dequeue is performed.
    /// - Note: `handler` closure is called before `update(with:)` method.
    open func register<T:ModelTransfer>(_ cellClass:T.Type, handler: @escaping (T, T.ModelType, IndexPath) -> Void = { _, _, _ in }, mapping: ((ViewModelMapping<T, T.ModelType>) -> Void)? = nil) where T: UICollectionViewCell
    {
        viewFactory.registerCellClass(T.self, handler: handler, mapping: mapping)
    }
    
    /// Registers mapping from `modelType` to `cellClass`. Mapping will automatically check for nib with the same name as `cellClass` and register it, if it is found. If cell is designed in storyboard, please set `mapping.cellRegisteredByStoryboard` property to `true` inside of `mapping` closure.
    /// - Parameters:
    ///   - cellClass: UICollectionViewCell to register
    ///   - modelType: Model type, which is mapped to `cellClass`.
    ///   - handler: configuration closure, that is run when cell is dequeued.
    ///   - mapping: mapping configuration closure, executed before any registration or dequeue is performed.
    open func register<Cell: UICollectionViewCell, Model>(_ cellClass: Cell.Type, for modelType: Model.Type, handler: @escaping (Cell, Model, IndexPath) -> Void, mapping: ((ViewModelMapping<Cell, Model>) -> Void)? = nil) {
        viewFactory.registerCellClass(cellClass, modelType, handler: handler, mapping: mapping)
    }

    /// Registers mapping for `headerClass`. `UICollectionView.elementKindSectionHeader` is used as a supplementary kind. Mapping will automatically check for nib with the same name as `headerClass` and register it, if it is found.
    /// If supplementary view is designed in storyboard, please set `mapping.supplementaryRegisteredByStoryboard` property to `true` inside of `mapping` closure.
    /// - Parameters:
    ///   - headerClass: UICollectionReusableView class to register
    ///   - modelType: Model type, which is mapped to `headerClass`.
    ///   - handler: configuration closure, that is run when supplementary view is dequeued.
    ///   - mapping: mapping configuration closure, executed before any registration or dequeue is performed.
    /// - Note: `handler` closure is called before `update(with:)` method.
    open func registerHeader<View:ModelTransfer>(_ headerClass : View.Type,
                                              handler: @escaping (View, View.ModelType, IndexPath) -> Void = { _, _, _ in },
                                              mapping: ((ViewModelMapping<View, View.ModelType>) -> Void)? = nil) where View: UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(View.self,
                                               ofKind: UICollectionView.elementKindSectionHeader,
                                               handler: handler,
                                               mapping: mapping)
    }
    
    /// Registers mapping from `modelType` to `headerClass`. `UICollectionView.elementKindSectionHeader` is used as a supplementary kind. Mapping will automatically check for nib with the same name as `headerClass` and register it, if it is found.
    /// If header is designed in storyboard, please set `mapping.supplementaryRegisteredByStoryboard` property to `true` inside of `mapping` closure.
    /// - Parameters:
    ///   - headerClass: UICollectionReusableView class to register
    ///   - modelType: Model type, which is mapped to `headerClass`.
    ///   - handler: configuration closure, that is run when header is dequeued.
    ///   - mapping: mapping configuration closure, executed before any registration or dequeue is performed.
    open func registerHeader<View:UICollectionReusableView, Model>(_ headerClass: View.Type, for modelType: Model.Type, handler: @escaping (View, Model, IndexPath) -> Void = { _, _, _ in }, mapping: ((ViewModelMapping<View, Model>) -> Void)? = nil) {
        registerSupplementary(View.self, for: Model.self, ofKind: UICollectionView.elementKindSectionHeader, handler: handler, mapping: mapping)
    }
    
    /// Registers mapping for `footerClass`. `UICollectionView.elementKindSectionFooter` is used as a supplementary kind. Mapping will automatically check for nib with the same name as `footerClass` and register it, if it is found.
    /// If supplementary view is designed in storyboard, please set `mapping.supplementaryRegisteredByStoryboard` property to `true` inside of `mapping` closure.
    /// - Parameters:
    ///   - footerClass: UICollectionReusableView class to register
    ///   - modelType: Model type, which is mapped to `footerClass`.
    ///   - handler: configuration closure, that is run when supplementary view is dequeued.
    ///   - mapping: mapping configuration closure, executed before any registration or dequeue is performed.
    /// - Note: `handler` closure is called before `update(with:)` method.
    open func registerFooter<View:ModelTransfer>(_ footerClass: View.Type,
                                              handler: @escaping (View, View.ModelType, IndexPath) -> Void = { _, _, _ in },
                                              mapping: ((ViewModelMapping<View, View.ModelType>) -> Void)? = nil) where View:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(View.self,
                                               ofKind: UICollectionView.elementKindSectionFooter,
                                               handler: handler,
                                               mapping: mapping)
    }
    
    /// Registers mapping from `modelType` to `footerClass`. `UICollectionView.elementKindSectionFooter` is used as a supplementary kind. Mapping will automatically check for nib with the same name as `footerClass` and register it, if it is found.
    /// If footer is designed in storyboard, please set `mapping.supplementaryRegisteredByStoryboard` property to `true` inside of `mapping` closure.
    /// - Parameters:
    ///   - footerClass: UICollectionReusableView class to register
    ///   - modelType: Model type, which is mapped to `footerClass`.
    ///   - handler: configuration closure, that is run when footer is dequeued.
    ///   - mapping: mapping configuration closure, executed before any registration or dequeue is performed.
    open func registerFooter<View:UICollectionReusableView, Model>(_ footerClass: View.Type, for modelType: Model.Type, handler: @escaping (View, Model, IndexPath) -> Void = { _, _, _ in }, mapping: ((ViewModelMapping<View, Model>) -> Void)? = nil) {
        registerSupplementary(View.self, for: Model.self, ofKind: UICollectionView.elementKindSectionFooter, handler: handler, mapping: mapping)
    }
    
    /// Registers mapping from model class to suppplementary view of `supplementaryClass` type for supplementary `kind`.
    ///
    /// Method will automatically check for nib with the same name as `supplementaryClass`. If it exists - nib will be registered instead of class.
    /// - Note: `handler` closure is called before `update(with:)` method.
    open func registerSupplementary<View:ModelTransfer>(_ supplementaryClass: View.Type,
                                                     ofKind kind: String,
                                                     handler: @escaping (View, View.ModelType, IndexPath) -> Void = { _, _, _ in },
                                                     mapping: ((ViewModelMapping<View, View.ModelType>) -> Void)? = nil) where View:UICollectionReusableView
    {
        viewFactory.registerSupplementaryClass(View.self, ofKind: kind, handler: handler, mapping: mapping)
    }
    
    /// Registers mapping from `modelType` to `supplementaryClass`. Mapping will automatically check for nib with the same name as `supplementaryClass` and register it, if it is found.
    /// If supplementary view is designed in storyboard, please set `mapping.supplementaryRegisteredByStoryboard` property to `true` inside of `mapping` closure.
    /// - Parameters:
    ///   - footerClass: UICollectionReusableView class to register
    ///   - modelType: Model type, which is mapped to `supplementaryClass`.
    ///   - handler: configuration closure, that is run when supplementary view is dequeued.
    ///   - mapping: mapping configuration closure, executed before any registration or dequeue is performed.
    open func registerSupplementary<View:UICollectionReusableView, Model>(_ supplementaryClass: View.Type, for modelType: Model.Type, ofKind kind: String, handler: @escaping (View, Model, IndexPath) -> Void = { _, _, _ in }, mapping: ((ViewModelMapping<View, Model>) -> Void)? = nil) {
        viewFactory.registerSupplementaryClass(supplementaryClass, modelType, ofKind: kind, handler: handler, mapping: mapping)
    }
    
    /// Unregisters `cellClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregister<Cell:ModelTransfer>(_ cellClass: Cell.Type) where Cell: UICollectionViewCell {
        viewFactory.unregisterCellClass(Cell.self)
    }
    
    /// Unregisters `headerClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterHeader<View:ModelTransfer>(_ headerClass: View.Type) where View:UICollectionReusableView {
        unregisterSupplementary(View.self, ofKind: UICollectionView.elementKindSectionHeader)
    }
    
    /// Unregisters `footerClass` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterFooter<View:ModelTransfer>(_ headerClass: View.Type) where View:UICollectionReusableView {
        unregisterSupplementary(View.self, ofKind: UICollectionView.elementKindSectionFooter)
    }
    
    /// Unregisters `supplementaryClass` of `kind` from `DTCollectionViewManager` and `UICollectionView`.
    open func unregisterSupplementary<View:ModelTransfer>(_ supplementaryClass: View.Type, ofKind kind: String) where View:UICollectionReusableView {
        viewFactory.unregisterSupplementaryClass(View.self, ofKind: kind)
    }
}
