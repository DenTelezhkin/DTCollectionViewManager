//
//  SwiftViewController.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 06.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

@objc(SwiftViewController)
class SwiftViewController: DTCollectionViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var refreshControl : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerCellClass(SwiftNumberCell.self, forModelClass:NSNumber.self)
        
        self.refreshControl = UIRefreshControl()
        self.collectionView.addSubview(self.refreshControl)
        self.refreshControl.addTarget(self, action: "refreshShouldStart:",
            forControlEvents: .ValueChanged)
        
        executeAfter(1, { () -> Void in
            self.memoryStorage().setItems(self.randomNumbers(), forSectionIndex: 0)
        })
    }
    
    func refreshShouldStart(sender: UIRefreshControl) {
        executeAfter(1, { () -> Void in
            self.refreshControl.endRefreshing()
            self.memoryStorage().setItems(self.randomNumbers(), forSectionIndex: 0)
        })
    }
    
    func randomNumbers() -> [Int] {
        var items = [Int]()
        
        for (var i=0; i<1 + Int(arc4random_uniform(20)); i++)
        {
            items.append(Int(arc4random_uniform(10)))
        }
        
        return items
    }
}

extension SwiftViewController: DTCollectionViewControllerEvents {
    override func collectionControllerDidUpdateContent() {
        if self.collectionView.numberOfItemsInSection(0) > 0
        {
            self.collectionView.hidden = false
            self.spinner.stopAnimating()
        }
        else {
            self.collectionView.hidden = true
        }
    }
}
