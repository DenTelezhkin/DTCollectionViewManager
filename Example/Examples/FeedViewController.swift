//
//  FeedViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 19.08.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTCollectionViewManager

class FeedViewController: UIViewController, DTCollectionViewManageable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.register(PostCell.self) { [weak self] mapping in
            mapping.sizeForCell { _, _ in
                self?.itemSize(for: self?.view.frame.size.width ?? .zero) ?? .zero
            }
            mapping.willDisplay { _, _, indexPath in
                if indexPath.item > (self?.numberOfItems ?? 0) - 5 {
                    // Showing last 5 posts, time to start loading new ones
                    self?.loadNextPage()
                }
            }
        }
        manager.register(ActivityIndicatorCell.self, for: ActivityIndicatorCell.Model.self) { [weak self] mapping in
            mapping.sizeForCell { _, _ in
                CGSize(width: self?.view.frame.size.width ?? 0, height: 50)
            }
        } handler: { _, _, _ in }
        manager.targetContentOffsetForProposedContentOffset { [weak self] point in
            // Restoring content offset to value, which was before rotation started and we updated layout
            self?.expectedTargetContentOffset ?? point
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction(handler: { [weak self] _ in
            // Emulate refreshing feed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.expectedTargetContentOffset = .zero
                self?.setInitialPage()
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        setInitialPage()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate { [weak self] context in
            self?.expectedTargetContentOffset = self?.collectionView.contentOffset ?? .zero
            self?.updateLayout(size: size, animated: true)
        } completion: { _ in }
    }
    
    private func setInitialPage() {
        manager.memoryStorage.setItems((0...25).map { _ in  Post() })
        manager.memoryStorage.addItem(ActivityIndicatorCell.Model())
    }
    
    private func loadNextPage() {
        guard !isLoadingNextPage else { return }
        isLoadingNextPage = true
        
        // Emulate loading next page
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.expectedTargetContentOffset = self?.collectionView.contentOffset ?? .zero
            try? self?.manager.memoryStorage.insertItems((0...25).map { _ in  Post() }, at: IndexPath(item: (self?.numberOfItems ?? 0) - 1, section: 0))
            self?.isLoadingNextPage = false
        }
    }
    
    private var isLoadingNextPage: Bool = false
    private var numberOfItems : Int {
        manager.memoryStorage.numberOfItems(inSection: 0)
    }
    private var expectedTargetContentOffset: CGPoint = .zero
    
    private func itemSize(for width: CGFloat) -> CGSize {
        if width > 500 {
            // Looks like wide-enough size for 2 columns
            return CGSize(width: (width - 30) / 2.0, height: 200)
        } else {
            // Only single column would fit
            return CGSize(width: width - 20, height: 200)
        }
    }
    
    private func updateLayout(size: CGSize, animated: Bool) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = itemSize(for: size.width)
        collectionView.setCollectionViewLayout(layout, animated: animated)
    }
}

