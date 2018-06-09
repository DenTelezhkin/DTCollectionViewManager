//
//  XibCollectionViewController.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager
#if swift(>=4.2)
class XibCollectionViewController: UICollectionViewController, DTCollectionViewNonOptionalManageable {}
#else
class XibCollectionViewController: UICollectionViewController, DTCollectionViewManageable {}
#endif
