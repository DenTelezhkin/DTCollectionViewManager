//
//  DiffableMultiSectionController.swift
//  Example
//
//  Created by Denys Telezhkin on 03.09.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager

class DiffableMultiSectionController: UICollectionViewController, DTCollectionViewManageable {

    convenience init() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        configuration.headerMode = .firstItemInSection
        self.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: configuration))
    }
    
    lazy var students: [String: [String]] = {
        (try? JSONDecoder().decode([String:[String]].self,
                                   from: NSDataAsset(name: "students")?.data ?? .init())) ?? [:]
    }()
    
    enum Section: String, CaseIterable {
        case gryffindor
        case ravenclaw
        case hufflepuff
        case slytherin
    }
    let searchController = UISearchController(searchResultsController: nil)
    var diffableDataSource : UICollectionViewDiffableDataSource<Section, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.register(UICollectionViewListCell.self, for: String.self) { cell, model, _ in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = model
            cell.contentConfiguration = configuration
        }
        diffableDataSource = manager.configureDiffableDataSource { indexPath, item in
            item
        }
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        updateUI(searchTerm: "", animated: false)
    }
    
    func updateUI(searchTerm: String, animated: Bool) {
        var snapshot : NSDiffableDataSourceSnapshot<Section, String> = .init()
        for section in Section.allCases {
            let studentsInClass = students[section.rawValue.capitalized]?.filter { $0.lowercased().contains(searchTerm.lowercased()) || searchTerm.isEmpty } ?? []
            if !studentsInClass.isEmpty {
                snapshot.appendSections([section])
                snapshot.appendItems([section.rawValue])
                snapshot.appendItems(studentsInClass)
            }
        }
        diffableDataSource?.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - UISearchResultsUpdating
@available(iOS 13, *)
extension DiffableMultiSectionController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateUI(searchTerm: searchController.searchBar.text ?? "", animated: true)
    }
}
