# CollectionViewUpdater

`CollectionViewUpdater` is a class, responsible for animating datasource updates.

### Reacting to content updates

Sometimes it's convenient to know, when data is updated, for example to hide UICollectionView, if there's no data. `CollectionViewUpdater` has `willUpdateContent` and `didUpdateContent` properties, that can help:

```swift
updater.willUpdateContent = { update in
  print("UI update is about to begin")
}

updater.didUpdateContent = { update in
  print("UI update finished")
}
```

Please keep in mind, that those closures will not be called if you directly invoke `collectionView.reloadData()`. If you need to call `reloadData` and trigger those closures, please call:

```swift
manager.collectionViewUpdater?.storageNeedsReloading()
```

### Customizing UICollectionView updates

`DTCollectionViewManager` uses `CollectionViewUpdater` class by default. While usually, you don't need to configure anything additional with `CollectionViewUpdater`, one exception to this rule is CoreData and `CoreDataStorage`.

When setting up CoreDataStorage with `DTTableViewManager` and `DTCollectionViewManager`, consider using special CoreData updater:

```swift
manager.collectionViewUpdater = manager.coreDataUpdater()

manager.tableViewUpdater = manager.coreDataUpdater()
```

This special version of updater has two important differences from default behavior:

1. Moving items is animated as insert and delete
2. When data model changes, `update(with:)` method and `handler` closure are called to update visible cells without explicitly reloading them.

Those are [recommended by Apple](https://developer.apple.com/documentation/coredata/nsfetchedresultscontrollerdelegate) approaches to handle `NSFetchedResultsControllerDelegate` updates with `UITableView` and `UICollectionView`.

If your `UICollectionView` is not on screen, it's updates are not required to be animated. For performance reasons you may want to disable offscreen animations:

```swift
manager.collectionViewUpdater.animateChangesOffScreen = false
```
