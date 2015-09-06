//
//  ViewModelMapping.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
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

extension ViewModelMapping : CustomStringConvertible
{
    var description : String
        {
            return "Mapping type : \(viewType) \n" +
                "View Type : \(viewTypeMirror.value) \n" +
            "Model Type : \(modelTypeMirror.value) \n"
    }
}