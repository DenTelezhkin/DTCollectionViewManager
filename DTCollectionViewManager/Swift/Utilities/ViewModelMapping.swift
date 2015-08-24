//
//  ViewModelMapping.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import DTModelStorage

enum ViewType : Equatable
{
    case Cell
    case SupplementaryView(kind: String)
    
    func supplementaryKind() -> String?
    {
        switch self
        {
        case .Cell: return nil
        case .SupplementaryView(let kind): return kind
        }
    }
}

func == (left: ViewType, right: ViewType) -> Bool
{
    switch left
    {
    case .Cell:
        switch right
        {
        case .Cell: return true
        default: return false
        }
    default: ()
    }
    
    return left.supplementaryKind() == right.supplementaryKind()
}

struct ViewModelMapping
{
    let viewType : ViewType
    let viewTypeMirror : _MirrorType
    let modelTypeMirror: _MirrorType
    let updateBlock : (Any, Any) -> Void
}