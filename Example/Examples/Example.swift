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
    case complexLayout
    
    var title: String {
        switch self {
            case .sections: return "Move sections"
            case .complexLayout: return "Complex layout"
        }
    }
    
    var controller : UIViewController {
        switch self {
            case .sections: return SectionsViewController(collectionViewLayout: UICollectionViewFlowLayout())
            case .complexLayout: return ComplexLayoutViewController()
        }
    }
}
