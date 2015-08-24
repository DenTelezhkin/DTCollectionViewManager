//
//  CollectionViewReaction.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

enum CollectionViewReactionType
{
    case Selection
    case CellConfiguration
    case SupplementaryConfiguration
    case ControllerWillUpdateContent
    case ControllerDidUpdateContent
}

protocol CollectionViewReactionData {}

extension NSIndexPath : CollectionViewReactionData {}

class CollectionViewReaction {
    let reactionType: CollectionViewReactionType
    var viewType : _MirrorType?
    var reactionBlock: ( () -> Void)?
    var reactionData: CollectionViewReactionData?
    var kind: String?
    
    func perform()
    {
        reactionBlock?()
    }
    
    init(reactionType: CollectionViewReactionType)
    {
        self.reactionType = reactionType
    }
}

struct ViewConfiguration : CollectionViewReactionData
{
    let view: UIView
    let indexPath: NSIndexPath
}

