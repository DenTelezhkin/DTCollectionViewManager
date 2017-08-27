//
//  DTCollectionViewDelegate.swift
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

import Foundation
import UIKit
import DTModelStorage

open class DTCollectionViewDelegate: DTCollectionViewDelegateWrapper, UICollectionViewDelegateFlowLayout {
    override func delegateWasReset() {
        collectionView?.delegate = nil
        collectionView?.delegate = self
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = performCellReaction(.sizeForItemAtIndexPath, location: indexPath, provideCell: false) as? CGSize {
            return size
        }
        return (delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        if let size = performSupplementaryReaction(forKind: UICollectionElementKindSectionHeader, signature: .referenceSizeForHeaderInSection, location: IndexPath(item:0, section:section), view: nil) as? CGSize {
            return size
        }
        if let size = (self.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) {
            return size
        }
        if let _ = (storage as? HeaderFooterStorage)?.headerModel(forSection: section) {
            return (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize ?? .zero
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let size = performSupplementaryReaction(forKind: UICollectionElementKindSectionFooter, signature: .referenceSizeForFooterInSection, location: IndexPath(item:0, section:section), view: nil) as? CGSize {
            return size
        }
        if let size = (self.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) {
            return size
        }
        if let _ = (storage as? HeaderFooterStorage)?.footerModel(forSection: section) {
            return (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize ?? .zero
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.shouldSelectItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, shouldSelectItemAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        _ = performCellReaction(.didSelectItemAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.shouldDeselectItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, shouldDeselectItemAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        _ = performCellReaction(.didDeselectItemAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
    {
        _ = performCellReaction(.didHighlightItemAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didHighlightItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
    {
        _ = performCellReaction(.didUnhighlightItemAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didUnhighlightItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.shouldHighlightItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, shouldHighlightItemAt: indexPath) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        defer { (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath) }
        guard let model = storage.item(at: indexPath) else { return }
        _ = collectionViewReactions.performReaction(of: .cell, signature: EventMethodSignature.willDisplayCellForItemAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        _ = performSupplementaryReaction(forKind: elementKind, signature: .willDisplaySupplementaryViewForElementKindAtIndexPath, location: indexPath, view: view)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        defer { (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath) }
        guard let model = storage.item(at: indexPath) else { return }
        _ = collectionViewReactions.performReaction(of: .cell, signature: EventMethodSignature.didEndDisplayingCellForItemAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        defer { (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath) }
        guard let model = (storage as? SupplementaryStorage)?.supplementaryModel(ofKind: elementKind, forSectionAt: indexPath) else { return }
        _ = collectionViewReactions.performReaction(of: .supplementaryView(kind: elementKind), signature: EventMethodSignature.didEndDisplayingSupplementaryViewForElementKindAtIndexPath.rawValue, view: view, model: model, location: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        if let can = performCellReaction(.shouldShowMenuForItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return can
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, shouldShowMenuForItemAt: indexPath) ?? false
    }
    
    open func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if let perform = perform5ArgumentCellReaction(.canPerformActionForItemAtIndexPath, argumentOne: action, argumentTwo: sender as Any, location: indexPath, provideCell: true) as? Bool {
            return perform
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender) ?? false
    }
    
    open func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        _ = perform5ArgumentCellReaction(.performActionForItemAtIndexPath, argumentOne: action, argumentTwo: sender as Any, location: indexPath, provideCell: true)
        (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    @available(iOS 9, tvOS 9, *)
    open func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.canFocusItemAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UICollectionViewDelegate)?.collectionView?(collectionView, canFocusItemAt: indexPath) ?? collectionView.cellForItem(at: indexPath)?.canBecomeFocused ?? true
    }
}
