//
//  ComplexLayoutViewController.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 06.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager

class ComplexLayoutViewController: UICollectionViewController, DTCollectionViewManageable {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager.startManagingWithDelegate(self)
        self.manager.registerCellClass(CollectionContainingCell.self)
        self.manager.memoryStorage.addItems([1,3,8,15])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.frame.width, height: layout.itemSize.height)
    }
    
    @IBAction func plusTapped(_ sender: AnyObject)
    {
        let controller = UIAlertController(title: nil, message: "How much cells do you need in collection view?", preferredStyle: .alert)
        controller.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let number = Int(controller.textFields!.first!.text!) {
                self.manager.memoryStorage.addItem(number)
            }
        }
        controller.addAction(cancelAction)
        controller.addAction(addAction)
        self.present(controller, animated: true, completion: nil)
    }
}
