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
public enum DTCollectionViewFactoryError : ErrorType, CustomStringConvertible
{
    case NilCellModel(NSIndexPath)
    case NilSupplementaryModel(kind: String, indexPath: NSIndexPath)
    case NoCellMappings(model: Any)
    case NoSupplementaryViewMapping(kind: String, model: Any)
    
    public var description : String {
        switch self {
        case .NilCellModel(let indexPath):
            return "Received nil model for cell at index path: \(indexPath)"
        case .NilSupplementaryModel(let kind, let indexPath):
            return "Received nil model for supplementary view of kind: \(kind) at index path: \(indexPath)"
        case .NoCellMappings(let model):
            return "Cell mapping is missing for model: \(model)"
        case .NoSupplementaryViewMapping(let kind, let model):
            return "Supplementary mapping of kind: \(kind) is missing for model: \(model)"
        }
    }
}

/// Internal class, that is used to create collection view cells and supplementary views.
class CollectionViewFactory
{
    private let collectionView: UICollectionView
    
    var mappings = [ViewModelMapping]()
    
    var bundle = NSBundle.mainBundle()
    
    weak var mappingCustomizableDelegate : DTViewModelMappingCustomizable?
    
    init(collectionView: UICollectionView)
    {
        self.collectionView = collectionView
    }
}

// MARK: Registration
extension CollectionViewFactory
{
    func registerCellClass<T:ModelTransfer where T: UICollectionViewCell>(cellClass: T.Type)
    {
        let reuseIdentifier = String(T)
        if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle) {
            collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: reuseIdentifier)
            mappings.addMappingForViewType(.Cell, viewClass: T.self, xibName: reuseIdentifier)
        }
        else {
            mappings.addMappingForViewType(.Cell, viewClass: T.self)
        }
        
    }
    
    func registerNiblessCellClass<T:ModelTransfer where T:UICollectionViewCell>(cellClass: T.Type)
    {
        let reuseIdentifier = String(T)
        collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func registerNibNamed<T:ModelTransfer where T: UICollectionViewCell>(nibName: String, forCellClass cellClass: T.Type)
    {
        let reuseIdentifier = String(T)
        assert(UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle))
        collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.Cell, viewClass: T.self, xibName: nibName)
    }
    
    func registerNiblessSupplementaryClass<T:ModelTransfer where T: UICollectionReusableView>(supplementaryClass: T.Type, forKind kind: String)
    {
        let reuseIdentifier = String(T)
        collectionView.registerClass(supplementaryClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.SupplementaryView(kind: kind), viewClass: T.self)
    }
    
    func registerSupplementaryClass<T:ModelTransfer where T:UICollectionReusableView>(supplementaryClass: T.Type, forKind kind: String)
    {
        let reuseIdentifier = String(T)
        if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: bundle) {
            self.collectionView.registerNib(UINib(nibName: reuseIdentifier, bundle: bundle), forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
            mappings.addMappingForViewType(.SupplementaryView(kind: kind), viewClass: T.self, xibName: reuseIdentifier)
        }
        else {
            mappings.addMappingForViewType(.SupplementaryView(kind: kind), viewClass: T.self)
        }
    }
    
    func registerNibNamed<T:ModelTransfer where T:UICollectionReusableView>(nibName: String, forSupplementaryClass supplementaryClass: T.Type, forKind kind: String)
    {
        let reuseIdentifier = String(T)
        assert(UINib.nibExistsWithNibName(nibName, inBundle: bundle))
        self.collectionView.registerNib(UINib(nibName: nibName, bundle: bundle), forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        mappings.addMappingForViewType(.SupplementaryView(kind: kind), viewClass: T.self, xibName: nibName)
    }
}

// MARK: View creation
extension CollectionViewFactory
{
    func cellForModel(model: Any, atIndexPath indexPath:NSIndexPath) throws -> UICollectionViewCell
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTCollectionViewFactoryError.NilCellModel(indexPath)
        }
        let mappingCandidates = mappings.mappingCandidatesForViewType(.Cell, model: unwrappedModel)
        let mapping : ViewModelMapping?
        
        if let customizedMapping = mappingCustomizableDelegate?.viewModelMappingFromCandidates(mappingCandidates, forModel: unwrappedModel) {
            mapping = customizedMapping
        } else if let defaultMapping = mappingCandidates.first {
            mapping = defaultMapping
        } else { mapping = nil }
        
        if mapping != nil {
            let cellClassName = String(mapping!.viewClass)
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellClassName, forIndexPath: indexPath)
            mapping?.updateBlock(cell, unwrappedModel)
            return cell
        }
        throw DTCollectionViewFactoryError.NoCellMappings(model: unwrappedModel)
    }

    func supplementaryViewOfKind(kind: String, forModel model: Any, atIndexPath indexPath: NSIndexPath) throws -> UICollectionReusableView
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTCollectionViewFactoryError.NilSupplementaryModel(kind: kind, indexPath: indexPath)
        }
        
        let mappingCandidates = mappings.mappingCandidatesForViewType(.SupplementaryView(kind: kind), model: unwrappedModel)
        let mapping : ViewModelMapping?
        
        if let customizedMapping = mappingCustomizableDelegate?.viewModelMappingFromCandidates(mappingCandidates, forModel: unwrappedModel) {
            mapping = customizedMapping
        } else if let defaultMapping = mappingCandidates.first {
            mapping = defaultMapping
        } else { mapping = nil }
        
        if mapping != nil
        {
            let viewClassName = String(mapping!.viewClass)
            let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: viewClassName, forIndexPath: indexPath)
            mapping!.updateBlock(reusableView, unwrappedModel)
            return reusableView
        }
        
        throw DTCollectionViewFactoryError.NoSupplementaryViewMapping(kind: kind, model: unwrappedModel)
    }
}