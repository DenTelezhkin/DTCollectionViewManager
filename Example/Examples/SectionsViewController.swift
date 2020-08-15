//
//  SectionsViewController.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager

class SectionsViewController: UICollectionViewController, DTCollectionViewManageable, UICollectionViewDelegateFlowLayout {

    var sectionNumber = 0
    
    private func barButton(title: String, action: @escaping (SectionsViewController) -> Void) -> UIBarButtonItem {
        UIBarButtonItem(title: title, image: nil, primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            action(self)
        }), menu: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        manager.register(UICollectionViewCell.self, for: UIColor.self, handler: { cell, model, _ in
            cell.backgroundColor = model
        })
        manager.registerHeader(SimpleTextCollectionReusableView.self)
        manager.registerFooter(SimpleTextCollectionReusableView.self)
        (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        manager.supplementaryStorage?.headerModelProvider = { index in "Section \(index) header" }
        manager.supplementaryStorage?.footerModelProvider = { index in "Section \(index) footer"}
        addSection()
        addSection()
        
        collectionView.backgroundColor = .white
        navigationItem.setRightBarButtonItems([
            barButton(title: "Add", action: { $0.addSection() }),
            barButton(title: "Remove", action: { $0.removeSection() }),
            barButton(title: "Move", action: { $0.moveSection() })
        ].reversed(), animated: false)
    }
    
    func addSection()
    {
        sectionNumber += 1
        let nextSection = manager.memoryStorage.sections.count > 0 ? manager.memoryStorage.sections.count : 0
        
        let section = SectionModel()
        section.items = [UIColor.random, UIColor.random, UIColor.random]
        manager.memoryStorage.insertSection(section, atIndex: nextSection)
    }

    func removeSection() {
        if manager.memoryStorage.sections.count > 0 {
            manager.memoryStorage.deleteSections(IndexSet(integer: manager.memoryStorage.sections.count - 1))
        }
    }
    func moveSection() {
        if manager.memoryStorage.sections.count > 0 {
            manager.memoryStorage.moveSection(manager.memoryStorage.sections.count - 1, toSection:0)
        }
    }
}
