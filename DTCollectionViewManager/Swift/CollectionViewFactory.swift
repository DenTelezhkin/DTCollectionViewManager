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
        var adjustedModelTypeMirror = RuntimeHelper.classClusterReflectionFromMirrorType(modelTypeMirror)
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
    
//    func registerSupplementaryClass
}