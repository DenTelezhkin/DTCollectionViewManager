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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch self {
            case .sections: return storyboard.instantiateViewController(withIdentifier: "SectionsViewController")
            case .complexLayout: return storyboard.instantiateViewController(withIdentifier: "ComplexLayoutViewController")
        }
    }
}
