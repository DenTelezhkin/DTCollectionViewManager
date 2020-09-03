//
//  Example.swift
//  Example
//
//  Created by Denys Telezhkin on 14.08.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

enum Example: CaseIterable {
    case sections
    case compositionalLayouts
    case pagination
    case diffableDatasource
    
    var title: String {
        switch self {
            case .sections: return "Move sections"
            case .compositionalLayouts: return "Compositional layout"
            case .pagination: return "Feed with load more / pull to refresh"
            case .diffableDatasource: return "Multi-section diffable datasource"
        }
    }
    
    var controller : UIViewController {
        switch self {
            case .sections: return UINavigationController(rootViewController: SectionsViewController(collectionViewLayout: UICollectionViewFlowLayout()))
            case .compositionalLayouts: return UINavigationController(rootViewController: CompositionalLayoutsViewController())
            case .pagination: return UINavigationController(rootViewController: FeedViewController(nibName: "FeedViewController", bundle: nil))
            case .diffableDatasource: return UINavigationController(rootViewController: DiffableMultiSectionController())
        }
    }
}
