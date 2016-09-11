# DTCollectionViewManager 5.0 Migration Guide

DTCollectionViewManager 5.0 is the latest major release of UICollectionView helper library for iOS and tvOS written in Swift 3. As a major release, following [Semantic Versioning conventions](https://semver.org), 5.0 introduces API-breaking changes.

This guide is provided in order to ease the transition of existing applications using DTCollectionViewManager 4.x to the latest APIs, as well as explain the design and structure of new and updated functionality.

- [Requirements](#requirements)
- [Benefits of Upgrading](#benefits-of-upgrading)
- [Breaking API Changes](#breaking-api-changes)
	- [Known migrator issues](#known-migrator-issues)
	- [Event system removals](#event-system-removals)
	- [Removed API](#removed-api)
- [New Features](#new-features)
	- [Events System](#events-system)
	- [Table View Updater](#table-view-updater)
  - [Unregister methods](#unregister-methods)
- [Updated Features](#updated-features)
  - [Supplementary Model Handling](#supplementary-model-handling)
  - [New Error Handling Model](#new-error-handling-model)
  - [Miscellaneous API additions](#miscellaneous-api-additions)

## Requirements

- iOS 8.0+ / tvOS 9.0+
- Xcode 8.0+
- Swift 3.0+

For those of you that would like to use DTCollectionViewManager with Swift 2.3 or Swift 2.2, please use the latest tagged 4.x release.

## Benefits of Upgrading

- **Complete Swift 3 Compatibility:** includes the full adoption of the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- **New Events System** introduces support for almost all `UICollectionViewDelegate`,`UICollectionViewDataSource` and `UICollectionViewDelegateFlowLayout` methods using closure-based API and generics.
- **New Collection View Updater** opens up API to customize UICollectionView updates.
- **New unregister methods** allow unregistering classes from `DTCollectionViewManager` and `UICollectionView`.
- **Improvements to supplementary models** allow working with supplementary views whose position is defined by IndexPath in UICollectionView.
- **Improved Error System:** uses a new `MemoryStorageError` type to adhere to the new pattern proposed in [SE-0112](https://github.com/apple/swift-evolution/blob/master/proposals/0112-nserror-bridging.md).

---

## Breaking API Changes

DTCollectionViewManager 5 has fully adopted all the new Swift 3 changes and conventions, including the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). Because of this, almost every API in DTCollectionViewManager has been modified in some way. When migrating to new release, remember to run Xcode Swift migrator, as lot of API have been annotated to automatically migrate to new syntax. There are however some cases, that Swift migrator is missing.

### Known migrator issues

`ModelTransfer` protocol syntax was updated to new design guidelines, however due to present associatedtype Swift migrator is missing all implementations of this protocol. As a workaround, you will need to rename methods manually:

```swift
// DTCollectionViewManager 4.x
class FooCell : UICollectionViewCell, ModelTransfer {
  func updateWithModel(model: Foo) {

  }
}

// DTCollectionViewManager 5.x
class FooCell : UICollectionViewCell, ModelTransfer {
  func update(with model: Foo) {

  }
}
```

`DTViewModelMappingCustomizable` protocol has been renamed to `ViewModelMappingCustomizing` and it's signature was changed:

```swift
// DTCollectionViewManager 4.x
func viewModelMappingFromCandidates(_ candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
   return ...
}

// DTCollectionViewManager 5.0
func viewModelMapping(fromCandidates candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
  return ...
}
```

### Event system removals

DTCollectionViewManager 4.x had rudimentary support for event handling in two forms - closure-based and method-pointer based, both supporting only 5 events(cell selection, cell, header and footer configuration, willDisplay cell). Goal of DTCollectionViewManager 5 was to support much more events in much more robust way. Because of that implementation needed to be reworked, and only one system needed to be kept to avoid maintainance burden and confusion when using API.

Closure-based system turned out to clearly be more powerful and logical, therefore all method-pointer based events have been removed. To find out more about new events system, refer to [new events system](#events-system) section.

Old closure-based events work the same way as before. The only change that was made is renaming of `whenSelected` method to better clarify it's behavior:

```swift
// DTCollectionViewManager 4.x
manager.whenSelected(FooCell.self) { cell, model, indexPath in }

// DTCollectionViewManager 5.x
manager.didSelect(FooCell.self) { cell, model, indexPath in }
```

#### Removed API

* Generic methods like `itemForCellClass:atIndexPath:` - they did not provide enough value to be present in a framework.
* `viewBundle` property on `DTCollectionViewManager` - bundle is now determined automatically
* `DTCollectionViewContentUpdatable` protocol - use `CollectionViewUpdater` `willUpdateContent` and `didUpdateContent` properties.

---

## New Features

### Events system

Events system was completely rewritten from scratch, and has support for **27** `UICollectionViewDelegate`, `UICollectionViewDataSource` and `UICollectionViewDelegateFlowLayout` methods. The way you use any of the events is really straightforward, for example here's how you can react to cell deselection:

```swift
manager.didDeselect(FooCell.self) { cell, model, indexPath in
  print("did deselect FooCell at \(indexPath), model: \(model)")
}
```

There are two types of events:

1. Event where we have underlying view at runtime
1. Event where we have only data model, because view has not been created yet.

In the first case, we are able to check view and model types, and pass them into closure. In the second case, however, if there's no view, we can't make any guarantees of which type it will be, therefore it loses view generic type and is not passed to closure. These two types of events have different signature, for example:

```swift
// Signature for didSelect event
// We do have a cell, when UICollectionView calls `collectionView(_:didSelectItemAt:)` method
open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UICollectionViewCell


// Signature for sizeForCell event
// When UICollectionView calls `collectionView(_:sizeForItemAt:)` method, cell is not created yet, so closure contains two arguments instead of three, and there are no guarantees made about cell type, only model type
open func sizeForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat)
```

It's also important to understand, that event system is implemented using `responds(to:)` method override and is working on the following rules:

* If `DTCollectionViewManageable` is implementing delegate method, `responds(to:)` returns true
* If `DTCollectionViewManager` has events tied to selector being called, `responds(to:)` also returns true

What this approach allows us to do, is configuring UICollectionView knowledge about what delegate method is implemented and what is not. For example, `DTCollectionViewManager` is implementing `collectionView(_:sizeForItemAt:)` method, however if you don't call `sizeForCell(withItem:_:)` method, you are safe to use self-sizing cells in UICollectionView. While **27** delegate methods are implemented, only those that have events or are implemented by delegate will be called by `UICollectionView`.

`DTCollectionViewManager` has the same approach for handling each delegate and datasource method:

* Try to execute event, if cell and model type satisfy requirements
* Try to call delegate or datasource method on `DTCollectionViewManageable` instance
* If two previous scenarios fail, fallback to whatever default `UICollectionView` has for this delegate or datasource method

Here's full list of all delegate and datasource methods implemented:

**UICollectionViewDataSource**

| DataSource method | Event method | Comment |
| ----------------- | ------------ | ------- |
|  cellForItemAt: | configure(_:_:) | Called after `update(with:)` method was called |
|  viewForSupplementaryElementOfKind:at: | configureSupplementary(_:ofKind:_:) | Called after `update(with:)` method was called |
|  viewForSupplementaryElementOfKind:at: | configureHeader(_:_:) | Called after `update(with:)` method was called |
|  viewForSupplementaryElementOfKind:at: | configureFooter(_:_:) | Called after `update(with:)` method was called |
|  canMoveItemAt: | canMove(_:_:) | - |

**UICollectionViewDelegate**

| Delegate method | Event method | Comment |
| ----------------- | ------------ | ------ |
|  shouldSelectItemAt: | shouldSelect(_:_:) | - |
|  didSelectItemAt: | didSelect(_:_:) | - |
|  shouldDeselectItemAt: | shouldDeselect(_:_:) | - |
|  didDeselectItemAt: | didDeselect(_:_:) | - |
|  shouldHighlightItemAt: | shouldHighlight(_:_:) | - |
|  didHighlightItemAt: | didHighlight(_:_:) | - |
|  didUnhighlightItemAt: | didUnhighlight(_:_:) | - |
|  willDisplay:forItemAt: | willDisplay(_:_:) | - |
|  willDisplaySupplementaryView:forElementOfKind:at: | willDisplaySupplementaryView(_:forElementKind:_:) | - |
|  willDisplaySupplementaryView:forElementOfKind:at: | willDisplayHeaderView(_:_:) | - |
|  willDisplaySupplementaryView:forElementOfKind:at: | willDisplayFooterView(_:_:) | - |
|  didEndDisplaying:forItemAt: | didEndDisplaying(_:_:) | - |
|  didEndDisplayingSupplementaryView:forElementOfKind:at: | didEndDisplayingSupplementaryView(_:forElementKind:_:) | - |
|  didEndDisplayingSupplementaryView:forElementOfKind:at: | didEndDisplayingHeaderView(_:_:) | - |
|  didEndDisplayingSupplementaryView:forElementOfKind:at: | didEndDisplayingFooterView(_:_:) | - |
|  shouldShowMenuForItemAt: | shouldShowMenu(for:_:) | - |
|  canPerformAction:forItemAt:withSender: | canPerformAction(for:_:) | - |
|  performAction:forItemAt:withSender: | performAction(for:_:) | - |
|  canFocusItemAt: | canFocus(_:_:) | iOS/tvOS 9+ |

**UICollectionViewDelegateFlowLayout**

| Delegate method | Event method | Comment |
| ----------------- | ------------ | ------ |
|  layout:sizeForItemAt: | sizeForCell(withItem:_:) | - |
|  layout:referenceSizeForHeaderInSection: | referenceSizeForHeaderView(withItem:_:) | - |
|  layout:referenceSizeForFooterInSection: | referenceSizeForFooterView(withItem:_:) | - |

### Collection View Updater

`DTCollectionViewManager` makes sure, that UI is always updated to state, representing storage. In 4.x release however, there was no way to customize how UI was updated. For example, when reloading cell, you might want animation to occur, or you might want to silently update your cell. This is actually how [Apple's guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html) for `NSFetchedResultsController` suggests you should do. Another interesting thing it suggests that .Move event reported by NSFetchedResultsController should be animated not as a move, but as deletion of old index path and insertion of new one.

In 4.x release `DTCollectionViewManager` itself served as collection view updater, implementing `StorageUpdating` protocol. 5.0 release introduces new property - `collectionViewUpdater`, that holds collection view updater object. All previous logic was extracted to separate `CollectionViewUpdater` class.

If you want to work with CoreData and NSFetchedResultsController, just call:

```swift
manager.collectionViewUpdater = manager.coreDataUpdater()
```

`CollectionViewUpdater` constructor allows customizing it's basic behaviour:

```swift
let updater = CollectionViewUpdater(collectionView: collectionView, reloadRow: { indexPath in
  // Reload row
}, animateMoveAsDeleteAndInsert: false)
```

`DTCollectionViewContentUpdatable` protocol was removed and it's methods have been moved to `CollectionViewUpdater`:

```swift
updater.willUpdateContent = { update in
  // prepare for updating
}
updater.didUpdateContent = { update in
  // update finished
}
```

These are all default options, however you might implement your own implementation of `CollectionViewUpdater`, the only requirement is that object needs to conform to `StorageUpdating` protocol. This gives you full control on how and when `DTCollectionViewManager` will update `UICollectionView`.

### Unregister methods

DTCollectionViewManager 5 introduces unregister methods, that allow unregistering from both `DTCollectionViewManager` and `UICollectionView`:

```swift
manager.unregister(FooCell.self)
manager.unregisterHeader(HeaderView.self)
manager.unregisterFooter(FooterView.self)
manager.unregisterSupplementary(SupplementaryView.self, forKind: "foo")
```

---

## Updated Features

DTCollectionViewManager 5 contains many enhancements on existing features. This section is designed to give a brief overview of the features and demonstrate their uses.

#### Supplementary model handling

In DTCollectionViewManager 4, supplementaries storage allowed only storing headers and footers, model that is sufficient for UITableView and UICollectionView with UICollectionViewFlowLayout, however insufficient, if you want to use UICollectionView with richer UICollectionViewLayout. Therefore underlying storage and methods for supplementary models has been changed to allow more supplementary view types in section.

```swift
// DTCollectionViewManager 4.x
let model = SectionModel()
model.setSupplementaryModel(1, forKind: "Kind")
model.supplementaryModelForKind("Kind") // 1

// DTCollectionViewManager 5.x
let model = SectionModel()
model.setSupplementaryModel(1, forKind: "Kind", atIndex: 0)
model.supplementaryModel(ofKind: "Kind", atIndex: 0) // 1
```

#### New Error handling model

DTCollectionViewManager 5 migrates to new error system, proposed in [SE-0112](https://github.com/apple/swift-evolution/blob/master/proposals/0112-nserror-bridging.md).

It makes much more easy to understand what error happened and how you should handle it.

For example:

```swift
do { try manager.memoryStorage.insertItem("Foo", at: NSIndexPath(item:0,section:0))}
catch let error as MemoryStorageError {
  print(error.localizedDescription)
}
```

#### Miscellaneous API Additions

* `SectionModel` and `RealmSection` objects now have `currentSectionIndex` property
* `DTCollectionViewManager` now has `isManagingCollectionView` Bool property
* `MemoryStorage` now has `removeItems(fromSection:)` method
* `DTCollectionViewManager` now has `updateCellClosure` that allows silently updating with model row at specific index path.
