//
//  DTCollectionViewManagerAnomalyHandler.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 03.05.2018.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
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
import DTModelStorage

#if swift(>=4.1)
public enum DTCollectionViewManagerAnomaly: Equatable, CustomDebugStringConvertible {
    
    case nilCellModel(IndexPath)
    case nilSupplementaryModel(kind: String, indexPath: IndexPath)
    case noCellMappingFound(modelDescription: String, indexPath: IndexPath)
    case noSupplementaryMappingFound(modelDescription: String, kind: String, indexPath: IndexPath)
    case differentCellReuseIdentifier(mappingReuseIdentifier: String, cellReuseIdentifier: String)
    case differentSupplementaryReuseIdentifier(mappingReuseIdentifier: String, supplementaryReuseIdentifier: String)
    case differentCellClass(xibName: String, cellClass: String, expectedCellClass: String)
    case differentSupplementaryClass(xibName: String, viewClass: String, expectedViewClass: String)
    case emptyXibFile(xibName: String, expectedViewClass: String)
    
    public var debugDescription: String {
        switch self {
        case .nilCellModel(let indexPath): return "❗️[DTCollectionViewManager] UICollectionView requested a cell at \(indexPath), however the model at that indexPath was nil."
        case .nilSupplementaryModel(kind: let kind, indexPath: let indexPath): return "❗️[DTCollectionViewManager] UICollectionView requested a supplementary view of kind: \(kind) at \(indexPath), however the model was nil."
        case .noCellMappingFound(modelDescription: let description, indexPath: let indexPath): return "❗️[DTCollectionViewManager] UICollectionView requested a cell for model at \(indexPath), but view model mapping for it was not found, model description: \(description)"
        case .noSupplementaryMappingFound(modelDescription: let description, kind: let kind, let indexPath):
            return "❗️[DTCollectionViewManager] UICollectionView requested a supplementary view of kind: \(kind) for model ar \(indexPath), but view model mapping for it was not found, model description: \(description)"
        case .differentCellReuseIdentifier(mappingReuseIdentifier: let mappingReuseIdentifier,
                                           cellReuseIdentifier: let cellReuseIdentifier):
            return "❗️[DTCollectionViewManager] Reuse identifier of UICollectionViewCell: \(cellReuseIdentifier) does not match reuseIdentifier used to register with UICollectionView: \(mappingReuseIdentifier). \n" +
                "If you are using XIB, please remove reuseIdentifier from XIB file, or change it to name of UICollectionViewCell subclass. If you are using Storyboards, please change UICollectionViewCell identifier to name of the class. \n" +
            "If you need different reuseIdentifier for any reason, you can change reuseIdentifier when registering mapping."
        case .differentCellClass(xibName: let xibName, cellClass: let cellClass, expectedCellClass: let expectedCellClass):
            return "⚠️[DTCollectionViewManager] Attempted to register xib \(xibName), but view found in a xib was of type \(cellClass), while expected type is \(expectedCellClass). This can prevent cells from being updated with models and react to events."
        case .differentSupplementaryClass(xibName: let xibName, viewClass: let viewClass, expectedViewClass: let expectedViewClass):
            return "⚠️[DTCollectionViewManager] Attempted to register xib \(xibName), but view found in a xib was of type \(viewClass), while expected type is \(expectedViewClass). This can prevent supplementary views from being updated with models and react to events."
        case .emptyXibFile(xibName: let xibName, expectedViewClass: let expectedViewClass):
            return "⚠️[DTCollectionViewManager] Attempted to register xib \(xibName) for \(expectedViewClass), but this xib does not contain any views."
        case .differentSupplementaryReuseIdentifier(mappingReuseIdentifier: let mappingIdentifier, supplementaryReuseIdentifier: let supplementaryIdentifier):
            return "❗️[DTCollectionViewManager] Reuse identifier of UICollectionReusableView: \(supplementaryIdentifier) does not match reuseIdentifier used to register with UICollectionView: \(mappingIdentifier). \n" +
                "If you are using XIB, please remove reuseIdentifier from XIB file, or change it to name of UICollectionReusableView subclass. If you are using Storyboards, please change UICollectionReusableView identifier to name of the class. \n" +
            "If you need different reuseIdentifier for any reason, you can change reuseIdentifier when registering mapping."
        }
    }
}


open class DTCollectionViewManagerAnomalyHandler : AnomalyHandler {
    open static var defaultAction : (DTCollectionViewManagerAnomaly) -> Void = { print($0.debugDescription) }
    
    open var anomalyAction: (DTCollectionViewManagerAnomaly) -> Void = DTCollectionViewManagerAnomalyHandler.defaultAction
    
    public init() {}
}
#endif
