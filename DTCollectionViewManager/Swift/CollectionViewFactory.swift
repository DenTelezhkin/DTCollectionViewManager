//
//  CollectionViewFactory.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

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
    func registerCellClass<T:ModelTransfer where T: UICollectionViewCell>(cellType: T.Type)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(_reflect(cellType))
        if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle) {
            collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: reuseIdentifier)
        }
        
        self.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func registerNibNamed<T:ModelTransfer where T: UICollectionViewCell>(nibName: String, forCellType cellType: T.Type)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(_reflect(cellType))
        assert(UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle))
        collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: reuseIdentifier)
        self.addMappingForViewType(.Cell, viewClass: T.self)
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
            assertionFailure("Received nil model at indexPath: \(indexPath)")
            return UICollectionViewCell()
        }
        
        let typeMirror = RuntimeHelper.mirrorFromModel(unwrappedModel)
        if let mapping = self.mappingForViewType(.Cell, modelTypeMirror: typeMirror)
        {
            let cellClassName = RuntimeHelper.classNameFromReflection(mapping.viewTypeMirror)
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellClassName, forIndexPath: indexPath)
            mapping.updateBlock(cell, unwrappedModel)
            return cell
        }
        
        assertionFailure("Unable to find cell mappings for type: \(_reflect(typeMirror.valueType).summary)")
        
        return UICollectionViewCell()
    }

    func supplementaryViewOfKind(kind: String, forModel model: Any, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            assertionFailure("Received nil model at indexPath: \(indexPath)")
            return UICollectionViewCell()
        }
        
        let typeMirror = RuntimeHelper.mirrorFromModel(unwrappedModel)
        if let mapping = self.mappingForViewType(ViewType.SupplementaryView(kind: kind), modelTypeMirror: typeMirror)
        {
            let viewClassName = RuntimeHelper.classNameFromReflection(mapping.viewTypeMirror)
            let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: viewClassName, forIndexPath: indexPath)
            mapping.updateBlock(reusableView, unwrappedModel)
            return reusableView
        }
        
        assertionFailure("Unable to find cell mappings for type: \(_reflect(typeMirror.valueType).summary)")
        
        return UICollectionReusableView()
    }
}