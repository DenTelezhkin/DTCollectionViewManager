//
//  DTCollectionViewManager+Drop.swift
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

import Foundation
import UIKit
import DTModelStorage

extension DTCollectionViewManager {
    #if os(iOS) && swift(>=3.2)
    
    // MARK: - Drop
    @available(iOS 11, *)
    open func performDropWithCoordinator(_ closure: @escaping (UICollectionViewDropCoordinator) -> Void) {
        collectionDropDelegate?.appendNonCellReaction(.performDropWithCoordinator, closure: closure)
    }
    
    @available(iOS 11, *)
    open func canHandleDropSession(_ closure: @escaping (UIDropSession) -> Bool) {
        collectionDropDelegate?.appendNonCellReaction(.canHandleDropSession, closure: closure)
    }
    
    @available(iOS 11, *)
    open func dropSessionDidEnter(_ closure: @escaping (UIDropSession) -> Void) {
        collectionDropDelegate?.appendNonCellReaction(.dropSessionDidEnter, closure: closure)
    }
    
    @available(iOS 11, *)
    open func dropSessionDidUpdate(_ closure: @escaping (UIDropSession, IndexPath?) -> UICollectionViewDropProposal) {
        collectionDropDelegate?.appendNonCellReaction(.dropSessionDidUpdate, closure: closure)
    }
    
    @available(iOS 11, *)
    open func dropSessionDidExit(_ closure: @escaping (UIDropSession) -> Void) {
        collectionDropDelegate?.appendNonCellReaction(.dropSessionDidExit, closure: closure)
    }
    
    @available(iOS 11, *)
    open func dropSessionDidEnd(_ closure: @escaping (UIDropSession) -> Void) {
        collectionDropDelegate?.appendNonCellReaction(.dropSessionDidEnd, closure: closure)
    }
    
    @available(iOS 11, *)
    open func dropPreviewParameters(_ closure: @escaping (IndexPath) -> UIDragPreviewParameters?) {
        collectionDropDelegate?.appendNonCellReaction(.dropPreviewParametersForItemAtIndexPath, closure: closure)
    }
    @available(iOS 11, *)
    open func drop(_ item: UIDragItem, to placeholder: UICollectionViewDropPlaceholder,
                   with coordinator: UICollectionViewDropCoordinator) -> DTCollectionViewDropPlaceholderContext {
        let context = coordinator.drop(item, to: placeholder)
        return DTCollectionViewDropPlaceholderContext(context: context, storage: storage)
    }
    
    #endif
}
