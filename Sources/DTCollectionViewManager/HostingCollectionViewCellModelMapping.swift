//
//  HostingCollectionViewCellModelMapping.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 24.06.2022.
//  Copyright © 2022 Denys Telezhkin. All rights reserved.
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
import SwiftUI
import DTModelStorage

// swiftlint:disable missing_docs

@available(iOS 13, tvOS 13, *)
public struct HostingCollectionViewCellConfiguration<Content:View> {
    public weak var parentController: UIViewController?
    public var hostingControllerMaker: (Content) -> UIHostingController<Content> = { UIHostingController(rootView: $0) }
    public var configureCell: (UICollectionViewCell) -> Void = { _ in }
    public var backgroundColor: UIColor? = .clear
    public var contentViewBackgroundColor: UIColor? = .clear
    public var hostingViewBackgroundColor: UIColor? = .clear
}

@available(iOS 13, tvOS 13, *)
open class HostingCellViewModelMapping<Content: View, Model>: CellViewModelMapping<Content, Model>, CellViewModelMappingProtocolGeneric {
    public typealias Cell = HostingCollectionViewCell<Content, Model>
    public typealias Model = Model
    
    public var configuration = HostingCollectionViewCellConfiguration<Content>()
    
    public var hostingCellSubclass: HostingCollectionViewCell<Content, Model>.Type = HostingCollectionViewCell.self {
        didSet {
            reuseIdentifier = "\(hostingCellSubclass.self)"
        }
    }
    
    /// Reuse identifier to be used for reusable cells. Mappings for UICollectionViewCell on iOS 14 / tvOS 14 and higher ignore this parameter.
    public var reuseIdentifier : String
    
    private var _cellConfigurationHandler: ((UICollectionViewCell, Any, IndexPath) -> Void)?
    private var _cellDequeueClosure: ((_ containerView: UICollectionView, _ model: Any, _ indexPath: IndexPath) -> UICollectionViewCell?)?
    private var _cellRegistration: Any?
    
    public init(cellContent: @escaping ((Model, IndexPath) -> Content),
                parentViewController: UIViewController?,
                mapping: ((HostingCellViewModelMapping<Content, Model>) -> Void)?) {
        reuseIdentifier = "\(HostingCollectionViewCell<Content, Model>.self)"
        super.init(viewClass: HostingCollectionViewCell<Content, Model>.self)
        configuration.parentController = parentViewController
        _cellDequeueClosure = { [weak self] collectionView, model, indexPath in
            guard let self = self else { return nil }
            if let model = model as? Model, #available(iOS 14, tvOS 14, *) {
                if let registration = self._cellRegistration as? UICollectionView.CellRegistration<HostingCollectionViewCell<Content, Model>, Model> {
                    return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: model)
                }
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath)
            if let cell = cell as? Cell, let model = model as? Model {
                cell.updateWith(rootView: cellContent(model, indexPath), configuration: self.configuration)            }
            return cell
        }
        _cellConfigurationHandler = { [weak self] cell, model, indexPath in
            guard let cell = cell as? HostingCollectionViewCell<Content, Model>, let model = model as? Model,
            let configuration = self?.configuration else { return }
            cell.updateWith(rootView: cellContent(model, indexPath), configuration: configuration)
        }
        mapping?(self)
        if #available(iOS 14, tvOS 14, *) {
            let registration = UICollectionView.CellRegistration<HostingCollectionViewCell<Content, Model>, Model>(handler: { [weak self] cell, indexPath, model in
                guard let configuration = self?.configuration else { return }
                cell.updateWith(rootView: cellContent(model, indexPath), configuration: configuration)
                })
            self._cellRegistration = registration
        }
    }
    
    open override func updateCell(cell: Any, at indexPath: IndexPath, with model: Any) {
        guard let cell = cell as? UICollectionViewCell else {
            preconditionFailure("Cannot update a cell, which is not a UITableViewCell")
        }
        _cellConfigurationHandler?(cell, model, indexPath)
    }
    
    open override func dequeueConfiguredReusableCell(for tableView: UITableView, model: Any, indexPath: IndexPath) -> UITableViewCell? {
        preconditionFailure("This method should not be used in UICollectionView cell view model mapping")
        
    }
    
    open override func dequeueConfiguredReusableCell(for collectionView: UICollectionView, model: Any, indexPath: IndexPath) -> UICollectionViewCell? {
        guard let cell = _cellDequeueClosure?(collectionView, model, indexPath) else {
            return nil
        }
        _cellConfigurationHandler?(cell, model, indexPath)
        return cell
    }
}
