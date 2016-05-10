//
//  SectionsViewController.swift
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager
import DTModelStorage

func randomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
}

class SectionsViewController: UIViewController, DTCollectionViewManageable, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView?
    var sectionNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.manager.startManagingWithDelegate(self)
        self.manager.registerCellClass(SolidColorCollectionCell)
        self.manager.registerHeaderClass(SimpleTextCollectionReusableView)
        self.manager.registerFooterClass(SimpleTextCollectionReusableView)
        (self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        (self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        
        self.addSection()
        self.addSection()
    }
    
    @IBAction func addSection()
    {
        sectionNumber += 1
        let nextSection = manager.memoryStorage.sections.count > 0 ? manager.memoryStorage.sections.count : 0
        
        let section = SectionModel()
        section.collectionHeaderModel = "Section \(sectionNumber) header"
        section.collectionFooterModel = "Section \(sectionNumber) footer"
        section.items = [randomColor(), randomColor(), randomColor()]
        manager.memoryStorage.insertSection(section, atIndex: nextSection)
    }

    @IBAction func removeSection(sender: AnyObject) {
        if self.manager.memoryStorage.sections.count > 0 {
            self.manager.memoryStorage.deleteSections(NSIndexSet(index: manager.memoryStorage.sections.count - 1))
        }
    }
    @IBAction func moveSection(sender: AnyObject) {
        if self.manager.memoryStorage.sections.count > 0 {
            self.manager.memoryStorage.moveSection(self.manager.memoryStorage.sections.count - 1, toSection:0)
        }
    }
}
