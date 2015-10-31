//
//  CollectionViewFactory.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 23.08.15.
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

/// Internal class, that is used to create collection view cells and supplementary views.
class CollectionViewFactory
{
    private let collectionView: UICollectionView
    
    private var mappings = [ViewModelMapping]()
    
    var bundle = NSBundle.mainBundle()
    
    init(collectionView: UICollectionView)
    {
        self.collectionView = collectionView
    }
}

private extension CollectionViewFactory
{
    func mappingForViewType(type: ViewType,modelTypeMirror: _MirrorType) -> ViewModelMapping?
    {
        let adjustedModelTypeMirror = RuntimeHelper.classClusterReflectionFromMirrorType(modelTypeMirror)
        return self.mappings.filter({ (mapping) -> Bool in
            return mapping.viewType == type && mapping.modelTypeMirror.summary == adjustedModelTypeMirror.summary
        }).first
    }
    
    func addMappingForViewType<T:ModelTransfer>(type: ViewType, viewClass : T.Type)
    {
        if self.mappingForViewType(type, modelTypeMirror: _reflect(T.ModelType.self)) == nil
        {
            self.mappings.append(ViewModelMapping(viewType : type,
                viewTypeMirror : _reflect(T),
                modelTypeMirror: _reflect(T.ModelType.self),
                updateBlock: { (view, model) in
                    (view as! T).updateWithModel(model as! T.ModelType)
            }))
        }
    }
}

// MARK: Registration
extension CollectionViewFactory
{
    func registerCellClass<T:ModelTransfer where T: UICollectionViewCell>(cellClass: T.Type)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(_reflect(cellClass))
        if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle) {
            collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: reuseIdentifier)
        }
        
        self.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func registerNiblessCellClass<T:ModelTransfer where T:UICollectionViewCell>(cellClass: T.Type)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(_reflect(cellClass))
        collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        self.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func registerNibNamed<T:ModelTransfer where T: UICollectionViewCell>(nibName: String, forCellClass cellClass: T.Type)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(_reflect(cellClass))
        assert(UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle))
        collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: reuseIdentifier)
        self.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func registerNiblessSupplementaryClass<T:ModelTransfer where T: UICollectionReusableView>(supplementaryClass: T.Type, forKind kind: String)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(_reflect(supplementaryClass))
        collectionView.registerClass(supplementaryClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        self.addMappingForViewType(ViewType.SupplementaryView(kind: kind), viewClass: T.self)
    }
    
    func registerSupplementaryClass<T:ModelTransfer where T:UICollectionReusableView>(supplementaryClass: T.Type, forKind kind: String)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(_reflect(supplementaryClass))
        if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle) {
            self.collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: bundle), forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        }
        self.addMappingForViewType(ViewType.SupplementaryView(kind: kind), viewClass: T.self)
    }
    
    func registerNibNamed<T:ModelTransfer where T:UICollectionReusableView>(nibName: String, forSupplementaryClass supplementaryClass: T.Type, forKind kind: String)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(_reflect(supplementaryClass))
        assert(UINib.nibExistsWithNibName(nibName, inBundle: bundle))
        self.collectionView.registerNib(UINib(nibName: nibName, bundle: bundle), forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        self.addMappingForViewType(ViewType.SupplementaryView(kind: kind), viewClass: T.self)
    }
}

// MARK: View creation
extension CollectionViewFactory
{
    func cellForModel(model: Any, atIndexPath indexPath:NSIndexPath) -> UICollectionViewCell
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            preconditionFailure("Received nil model at indexPath: \(indexPath)")
        }
        
        let typeMirror = RuntimeHelper.mirrorFromModel(unwrappedModel)
        if let mapping = self.mappingForViewType(.Cell, modelTypeMirror: typeMirror)
        {
            let cellClassName = RuntimeHelper.classNameFromReflection(mapping.viewTypeMirror)
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellClassName, forIndexPath: indexPath)
            mapping.updateBlock(cell, unwrappedModel)
            return cell
        }
        preconditionFailure("Unable to find cell mappings for type: \(_reflect(typeMirror.valueType).summary)")
    }

    func supplementaryViewOfKind(kind: String, forModel model: Any, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            preconditionFailure("Received nil model at indexPath: \(indexPath)")
        }
        
        let typeMirror = RuntimeHelper.mirrorFromModel(unwrappedModel)
        if let mapping = self.mappingForViewType(ViewType.SupplementaryView(kind: kind), modelTypeMirror: typeMirror)
        {
            let viewClassName = RuntimeHelper.classNameFromReflection(mapping.viewTypeMirror)
            let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: viewClassName, forIndexPath: indexPath)
            mapping.updateBlock(reusableView, unwrappedModel)
            return reusableView
        }
        
        preconditionFailure("Unable to find supplementary mappings for kind: \(kind) of type: \(_reflect(typeMirror.valueType).summary)")
    }
}