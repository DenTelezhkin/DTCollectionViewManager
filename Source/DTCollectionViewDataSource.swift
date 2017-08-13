//
//  DTCollectionViewDataSource.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 13.08.17.
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

open class DTCollectionViewDataSource: DTCollectionViewDelegateWrapper, UICollectionViewDataSource {
    override func delegateWasReset() {
        // _ = collectionView?.numberOfSections is a
        // workaround, that prevents UICollectionView from being confused about it's own number of sections
        // This happens mostly on UICollectionView creation, before any delegate methods have been called and is not reproducible after it was fully initialized.
        // This is rare, and is not documented anywhere, but since workaround is small and harmless, we are including it
        // as a part of DTCollectionViewManager framework.
        
        collectionView?.dataSource = nil
        _ = collectionView?.numberOfSections
        collectionView?.dataSource = self
        _ = collectionView?.numberOfSections
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storage.sections[section].numberOfItems
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return storage.sections.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = storage.item(at: indexPath), let model = RuntimeHelper.recursivelyUnwrapAnyValue(item) else {
            handleCollectionViewFactoryError(DTCollectionViewFactoryError.nilCellModel(indexPath))
            return UICollectionViewCell()
        }
        
        let cell : UICollectionViewCell
        do {
            cell = try viewFactory.cellForModel(model, atIndexPath: indexPath)
        } catch let error as DTCollectionViewFactoryError {
            handleCollectionViewFactoryError(error)
            cell = UICollectionViewCell()
        } catch {
            cell = UICollectionViewCell()
        }
        _ = collectionViewReactions.performReaction(of: .cell,
                                                    signature: EventMethodSignature.configureCell.rawValue,
                                                    view: cell,
                                                    model: model,
                                                    location: indexPath)
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if let model = (self.storage as? SupplementaryStorage)?.supplementaryModel(ofKind: kind, forSectionAt: indexPath) {
            let view : UICollectionReusableView
            do {
                view = try viewFactory.supplementaryViewOfKind(kind, forModel: model, atIndexPath: indexPath)
            } catch let error as DTCollectionViewFactoryError {
                handleCollectionViewFactoryError(error)
                view = UICollectionReusableView()
            } catch {
                view = UICollectionReusableView()
            }
            _ = collectionViewReactions.performReaction(of: .supplementaryView(kind: kind),
                                                        signature: EventMethodSignature.configureSupplementary.rawValue,
                                                        view: view,
                                                        model: model,
                                                        location: indexPath)
            return view
        }
        handleCollectionViewFactoryError(.nilSupplementaryModel(kind: kind, indexPath: indexPath))
        return UICollectionReusableView()
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.canMoveItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDataSource)?.collectionView?(collectionView, canMoveItemAt: indexPath) ?? true
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    open func collectionView(_ collectionView: UICollectionView, moveItemAt source: IndexPath, to destination: IndexPath) {
        if (delegate as? UICollectionViewDataSource)?.collectionView?(collectionView, moveItemAt: source, to: destination) != nil {
            return
        }
        if let storage = self.storage as? MemoryStorage
        {
            if let from = storage.sections[source.section] as? SectionModel,
                let to = storage.sections[destination.section] as? SectionModel
            {
                let item = from.items[source.row]
                from.items.remove(at: source.row)
                to.items.insert(item, at: destination.row)
            }
        }
    }
}
