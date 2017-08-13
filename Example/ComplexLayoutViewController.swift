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
        
        manager.startManaging(withDelegate: self)
        manager.register(CollectionContainingCell.self)
        manager.sizeForCell(withItem: Int.self) { [weak self] _, _ in
            guard let layout = self?.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
            return CGSize(width: self?.collectionView?.frame.width ?? 0, height: layout.itemSize.height)
        }
        manager.memoryStorage.addItems([1,3,8,15])
    }
    
    @IBAction func plusTapped(_ sender: AnyObject)
    {
        let controller = UIAlertController(title: nil, message: "How much cells do you need in collection view?", preferredStyle: .alert)
        controller.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if let number = Int(controller.textFields!.first!.text!) {
                self?.manager.memoryStorage.addItem(number)
            }
        }
        controller.addAction(cancelAction)
        controller.addAction(addAction)
        present(controller, animated: true, completion: nil)
    }
}
