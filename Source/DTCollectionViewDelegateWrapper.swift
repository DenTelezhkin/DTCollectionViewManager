//
//  DTCollectionViewDelegateWrapper.swift
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

open class DTCollectionViewDelegateWrapper : NSObject {
    weak var delegate: AnyObject?
    weak var collectionView: UICollectionView? { return manager.collectionView }
    var viewFactory: CollectionViewFactory { return manager.viewFactory }
    var storage: Storage { return manager.storage }
    var viewFactoryErrorHandler: ((DTCollectionViewFactoryError) -> Void)? { return manager.viewFactoryErrorHandler }
    private unowned let manager: DTCollectionViewManager
    
    init(delegate: AnyObject?, collectionViewManager: DTCollectionViewManager) {
        self.delegate = delegate
        manager = collectionViewManager
    }
    
    /// Array of `DTCollectionViewManager` reactions
    /// - SeeAlso: `EventReaction`.
    final var collectionViewReactions = ContiguousArray<EventReaction>()  {
        didSet {
            delegateWasReset()
        }
    }
    
    func delegateWasReset() {
        // Subclasses need to override this method, resetting `UICollectionView` delegate or datasource.
        // Resetting delegate and dataSource are needed, because UICollectionView caches results of `respondsToSelector` call, and never calls it again until `setDelegate` method is called.
        // We force UICollectionView to flush that cache and query us again, because with new event we might have new delegate or datasource method to respond to.
    }
    
    
    /// Calls `viewFactoryErrorHandler` with `error`. If it's nil, prints error into console and asserts.
    @nonobjc final func handleCollectionViewFactoryError(_ error: DTCollectionViewFactoryError) {
        if let handler = viewFactoryErrorHandler {
            handler(error)
        } else {
            print(error.description)
            assertionFailure(error.description)
        }
    }
    
    func appendReaction<T,U>(for cellClass: T.Type, signature: EventMethodSignature, closure: @escaping (T,T.ModelType, IndexPath) -> U) where T: ModelTransfer, T:UICollectionViewCell
    {
        let reaction = EventReaction(signature: signature.rawValue, viewType: .cell, viewClass: T.self)
        reaction.makeReaction(closure)
        collectionViewReactions.append(reaction)
    }
    
    func appendReaction<T,U>(for modelClass: T.Type, signature: EventMethodSignature, closure: @escaping (T, IndexPath) -> U)
    {
        let reaction = EventReaction(signature: signature.rawValue, viewType: .cell, modelType: T.self)
        reaction.makeReaction(closure)
        collectionViewReactions.append(reaction)
    }
    
    func appendReaction<T,U>(forSupplementaryKind kind: String, supplementaryClass: T.Type, signature: EventMethodSignature, closure: @escaping (T, T.ModelType, IndexPath) -> U) where T: ModelTransfer, T: UICollectionReusableView {
        let reaction = EventReaction(signature: signature.rawValue, viewType: .supplementaryView(kind: kind), viewClass: T.self)
        reaction.makeReaction(closure)
        collectionViewReactions.append(reaction)
    }
    
    func appendReaction<T,U>(forSupplementaryKind kind: String, modelClass: T.Type, signature: EventMethodSignature, closure: @escaping (T, IndexPath) -> U) {
        let reaction = EventReaction(signature: signature.rawValue, viewType: .supplementaryView(kind: kind), modelType: T.self)
        reaction.makeReaction(closure)
        collectionViewReactions.append(reaction)
    }
    
    func performCellReaction(_ signature: EventMethodSignature, location: IndexPath, provideCell: Bool) -> Any? {
        var cell : UICollectionViewCell?
        if provideCell { cell = collectionView?.cellForItem(at:location) }
        guard let model = storage.item(at: location) else { return nil }
        return collectionViewReactions.performReaction(of: .cell, signature: signature.rawValue, view: cell, model: model, location: location)
    }
    
    func performSupplementaryReaction(forKind kind: String, signature: EventMethodSignature, location: IndexPath, view: UICollectionReusableView?) -> Any? {
        guard let model = (storage as? SupplementaryStorage)?.supplementaryModel(ofKind: kind, forSectionAt: location) else { return nil }
        return collectionViewReactions.performReaction(of: .supplementaryView(kind: kind), signature: signature.rawValue, view: view, model: model, location: location)
    }
    
    // MARK: - Target Forwarding
    
    /// Forwards `aSelector`, that is not implemented by `DTCollectionViewManager` to delegate, if it implements it.
    ///
    /// - Returns: `DTCollectionViewManager` delegate
    open override func forwardingTarget(for aSelector: Selector) -> Any? {
        return delegate
    }
    
    /// Returns true, if `DTCollectionViewManageable` implements `aSelector`, or `DTCollectionViewManager` has an event, associated with this selector.
    ///
    /// - SeeAlso: `EventMethodSignature`
    open override func responds(to aSelector: Selector) -> Bool {
        if self.delegate?.responds(to: aSelector) ?? false {
            return true
        }
        if super.responds(to: aSelector) {
            if let eventSelector = EventMethodSignature(rawValue: String(describing: aSelector)) {
                return collectionViewReactions.contains(where: { $0.methodSignature == eventSelector.rawValue })
            }
            return true
        }
        return false
    }
}
