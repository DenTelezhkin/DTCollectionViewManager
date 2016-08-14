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

/// Errors, that can be thrown by `CollectionViewFactory` if it fails to create a cell or supplementary view because of various reasons. 
/// These errors are handled by `DTCollectionViewManager` class.
public enum DTCollectionViewFactoryError : Error, CustomStringConvertible
{
    case nilCellModel(IndexPath)
    case nilSupplementaryModel(kind: String, indexPath: IndexPath)
    case noCellMappings(model: Any)
    case noSupplementaryViewMapping(kind: String, model: Any)
    
    public var description : String {
        switch self {
        case .nilCellModel(let indexPath):
            return "Received nil model for cell at index path: \(indexPath)"
        case .nilSupplementaryModel(let kind, let indexPath):
            return "Received nil model for supplementary view of kind: \(kind) at index path: \(indexPath)"
        case .noCellMappings(let model):
            return "Cell mapping is missing for model: \(model)"
        case .noSupplementaryViewMapping(let kind, let model):
            return "Supplementary mapping of kind: \(kind) is missing for model: \(model)"
        }
    }
}

/// Internal class, that is used to create collection view cells and supplementary views.
class CollectionViewFactory
{
    private let collectionView: UICollectionView
    
    var mappings = [ViewModelMapping]()
    
    weak var mappingCustomizableDelegate : DTViewModelMappingCustomizable?
    
    init(collectionView: UICollectionView)
    {
        self.collectionView = collectionView
    }
}

// MARK: Registration
extension CollectionViewFactory
{
    func registerCellClass<T:ModelTransfer where T: UICollectionViewCell>(_ cellClass: T.Type)
    {
        let reuseIdentifier = String(T.self)
        if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: Bundle(for: T.self)) {
            collectionView.register(UINib(nibName: reuseIdentifier, bundle: Bundle(for: T.self)), forCellWithReuseIdentifier: reuseIdentifier)
            mappings.addMappingForViewType(.cell, viewClass: T.self, xibName: reuseIdentifier)
        }
        else {
            mappings.addMappingForViewType(.cell, viewClass: T.self)
        }
        
    }
    
    func registerNiblessCellClass<T:ModelTransfer where T:UICollectionViewCell>(_ cellClass: T.Type)
    {
        let reuseIdentifier = String(T.self)
        collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.cell, viewClass: T.self)
    }
    
    func registerNibNamed<T:ModelTransfer where T: UICollectionViewCell>(_ nibName: String, forCellClass cellClass: T.Type)
    {
        let reuseIdentifier = String(T.self)
        assert(UINib.nibExistsWithNibName(reuseIdentifier, inBundle: Bundle(for: T.self)))
        collectionView.register(UINib(nibName: reuseIdentifier, bundle: Bundle(for: T.self)), forCellWithReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.cell, viewClass: T.self, xibName: nibName)
    }
    
    func registerNiblessSupplementaryClass<T:ModelTransfer where T: UICollectionReusableView>(_ supplementaryClass: T.Type, forKind kind: String)
    {
        let reuseIdentifier = String(T.self)
        collectionView.register(supplementaryClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.supplementaryView(kind: kind), viewClass: T.self)
    }
    
    func registerSupplementaryClass<T:ModelTransfer where T:UICollectionReusableView>(_ supplementaryClass: T.Type, forKind kind: String)
    {
        let reuseIdentifier = String(T.self)
        if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: Bundle(for: T.self)) {
            self.collectionView.register(UINib(nibName: reuseIdentifier, bundle: Bundle(for: T.self)), forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
            mappings.addMappingForViewType(.supplementaryView(kind: kind), viewClass: T.self, xibName: reuseIdentifier)
        }
        else {
            mappings.addMappingForViewType(.supplementaryView(kind: kind), viewClass: T.self)
        }
    }
    
    func registerNibNamed<T:ModelTransfer where T:UICollectionReusableView>(_ nibName: String, forSupplementaryClass supplementaryClass: T.Type, forKind kind: String)
    {
        let reuseIdentifier = String(T.self)
        assert(UINib.nibExistsWithNibName(nibName, inBundle: Bundle(for: T.self)))
        self.collectionView.register(UINib(nibName: nibName, bundle: Bundle(for: T.self)), forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.supplementaryView(kind: kind), viewClass: T.self, xibName: nibName)
    }
}

// MARK: View creation
extension CollectionViewFactory
{
    func cellForModel(_ model: Any, atIndexPath indexPath:IndexPath) throws -> UICollectionViewCell
    {
        let mappingCandidates = mappings.mappingCandidatesForViewType(.cell, model: model)
        let mapping : ViewModelMapping?
        
        if let customizedMapping = mappingCustomizableDelegate?.viewModelMappingFromCandidates(mappingCandidates, forModel: model) {
            mapping = customizedMapping
        } else if let defaultMapping = mappingCandidates.first {
            mapping = defaultMapping
        } else { mapping = nil }
        
        if mapping != nil {
            let cellClassName = String(mapping!.viewClass)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClassName, for: indexPath)
            mapping?.updateBlock(cell, model)
            return cell
        }
        throw DTCollectionViewFactoryError.noCellMappings(model: model)
    }

    func supplementaryViewOfKind(_ kind: String, forModel model: Any, atIndexPath indexPath: IndexPath) throws -> UICollectionReusableView
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTCollectionViewFactoryError.nilSupplementaryModel(kind: kind, indexPath: indexPath)
        }
        
        let mappingCandidates = mappings.mappingCandidatesForViewType(.supplementaryView(kind: kind), model: unwrappedModel)
        let mapping : ViewModelMapping?
        
        if let customizedMapping = mappingCustomizableDelegate?.viewModelMappingFromCandidates(mappingCandidates, forModel: unwrappedModel) {
            mapping = customizedMapping
        } else if let defaultMapping = mappingCandidates.first {
            mapping = defaultMapping
        } else { mapping = nil }
        
        if mapping != nil
        {
            let viewClassName = String(mapping!.viewClass)
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewClassName, for: indexPath)
            mapping!.updateBlock(reusableView, unwrappedModel)
            return reusableView
        }
        
        throw DTCollectionViewFactoryError.noSupplementaryViewMapping(kind: kind, model: unwrappedModel)
    }
}
