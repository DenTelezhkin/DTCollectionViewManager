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
    
    var title: String {
        switch self {
            case .sections: return "Move sections"
            case .compositionalLayouts: return "Compositional layout"
        }
    }
    
    var controller : UIViewController {
        switch self {
            case .sections: return SectionsViewController(collectionViewLayout: UICollectionViewFlowLayout())
            case .compositionalLayouts: return CompositionalLayoutsViewController()
        }
    }
}
