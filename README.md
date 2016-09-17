![Build Status](https://travis-ci.org/DenHeadless/DTCollectionViewManager.svg?branch=master) &nbsp;
[![codecov.io](http://codecov.io/github/DenHeadless/DTCollectionViewManager/coverage.svg?branch=master)](http://codecov.io/github/DenHeadless/DTCollectionViewManager?branch=master)
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTCollectionViewManager/badge.svg) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTCollectionViewManager/badge.svg) &nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)]()

DTCollectionViewManager 5
================
> This is a sister-project for [DTTableViewManager](https://github.com/DenHeadless/DTTableViewManager) - great tool for UITableView management, built on the same principles.

Powerful generic-based UICollectionView management framework, written in Swift 3.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Usage](#usage)
    - **Intro -** [Mapping and Registration](#mapping-and-registration), [Data Models](#data-models)
    - **Storage classes -** [Memory Storage](#memorystorage), [CoreDataStorage](#coredatastorage), [RealmStorage](#realmstorage)
    - **Reacting to events -** [Event types](#event-types), [Events list](#events-list)
- [Advanced Usage](#advanced-usage)
	- [Reacting to content updates](#reacting-to-content-updates)
	- [Customizing UICollectionView updates](#customizing-uicollectionview-updates)
  - [Customizing mapping resolution](#customizing-mapping-resolution)
  - [Unregistering mappings](#unregistering-mappings)
  - [Error reporting](#error-reporting)
- [ObjectiveC support](#objectivec-support)
- [Documentation](#documentation)
- [Running example project](#running-example-project)
- [Thanks](#thanks)

## Features

- [x] Powerful mapping system between data models and cells, headers and footers
- [x] Support for all Swift types - classes, structs, enums, tuples
- [x] Support for protocols and subclasses as data models
- [x] Powerful events system, that covers most of UICollectionView delegate methods
- [x] Views created from code, XIB, or storyboard
- [x] Flexible Memory/CoreData/Realm.io storage options
- [x] Automatic datasource and interface synchronization.
- [x] Automatic XIB registration and dequeue
- [x] No type casts required
- [x] No need to subclass
- [x] Can be used with UICollectionViewController, or UIViewController with UICollectionView, or any other class, that contains UICollectionView

## Requirements

* Xcode 8 and higher
* iOS 8.0 and higher / tvOS 9.0 and higher
* Swift 3

## Installation

[CocoaPods](http://www.cocoapods.org):

    pod 'DTCollectionViewManager', '~> 5.0.0-beta.1'

[Carthage](https://github.com/Carthage/Carthage):

    github "DenHeadless/DTCollectionViewManager" ~> 5.0.0-beta.1

After running `carthage update` drop DTCollectionViewManager.framework and DTModelStorage.framework to Xcode project embedded binaries.

## Quick start

`DTCollectionViewManager` framework has two parts - core framework, and storage classes. Import them both to your view controller class to start:

```swift
import DTCollectionViewManager
import DTModelStorage
```

The core object of a framework is `DTCollectionViewManager`. Declare your class as `DTCollectionViewManageable`, and it will be automatically injected with `manager` property, that will hold an instance of `DTCollectionViewManager`.

Make sure your UICollectionView outlet is wired to your class and call in viewDidLoad:

```swift
	manager.startManaging(withDelegate:self)
```

Let's say you have an array of Posts you want to display in UICollectionView. To quickly show them using DTCollectionViewManager, here's what you need to do:

* Create UICollectionViewCell subclass, let's say PostCell. Adopt ModelTransfer protocol

```swift
class PostCell : UICollectionViewCell, ModelTransfer {
	func update(with model: Post) {
		// Fill your cell with actual data
	}
}
```

* Call registration methods on your `DTCollectionViewManageable` instance

```swift
	manager.register(PostCell.self)
```

ModelType will be automatically gathered from your `PostCell`. If you have a PostCell.xib file, it will be automatically registered for PostCell. If you have a storyboard with PostCell, set it's reuseIdentifier to be identical to class - "PostCell".

* Add your posts!

```swift
	manager.memoryStorage.addItems(posts)
```

That's it! It's that easy!

## Usage

### Mapping and registration

Cells:
* `register(_:)`
* `registerNibNamed(_:for:)`
* `registerNibless(_:)`

Headers and footers:
* `registerHeader(_:)`
* `registerNibNamed(_:forHeader:)`
* `registerNiblessHeader(_:)`
* `registerFooter(_:)`
* `registerNibNamed(_:forFooter:)`
* `registerNiblessFooter(_:)`

Supplementaries:
* `registerSupplementary(_:forKind:)`
* `registerNibNamed(_:forSupplementary:ofKind:)`
* `registerNiblessSupplementary(_:forKind:)`

### Data models

`DTCollectionViewManager` supports all Swift and Objective-C types as data models. This also includes protocols and subclasses.

```swift
protocol Food {}
class Apple : Food {}
class Carrot: Food {}

class FoodCollectionViewCell : UICollectionViewCell, ModelTransfer {
    func update(with model: Food) {
        // Display food in a cell
    }
}
manager.register(FoodCollectionViewCell.self)
manager.memoryStorage.addItems([Apple(),Carrot()])
```

Mappings are resolved simply by calling `is` type-check. In our example Apple is Food and Carrot is Food, so mapping will work.

## Storage classes

[DTModelStorage](https://github.com/DenHeadless/DTModelStorage/) is a framework, that provides storage classes for `DTCollectionViewManager`. By default, storage property on `DTCollectionViewManager` holds a `MemoryStorage` instance.

### MemoryStorage

`MemoryStorage` is a class, that manages UICollectionView models in memory. It has methods for adding, removing, replacing, reordering table view models etc. You can read all about them in [DTModelStorage repo](https://github.com/DenHeadless/DTModelStorage#memorystorage). Basically, every section in `MemoryStorage` is an array of `SectionModel` objects, which itself is an object, that contains optional header and footer models, and array of table items.

### CoreDataStorage

`CoreDataStorage` is meant to be used with `NSFetchedResultsController`. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UICollectionView, is create CoreDataStorage object and set it on your `storage` property of `DTCollectionViewManager`.

It also recommended to use built-in CoreData updater to properly update UICollectionView:

```swift
manager.collectionViewUpdater = manager.coreDataUpdater()
```

Standard flow for creating `CoreDataStorage` can be something like this:

```swift
let request = NSFetchRequest<Post>()
request.entity = NSEntityDescription.entity(forEntityName: String(Post.self), in: context)
request.fetchBatchSize = 20
request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
let fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
_ = try? fetchResultsController.performFetch()

manager.storage = CoreDataStorage(fetchedResultsController: fetchResultsController)
```

Keep in mind, that MemoryStorage is not limited to objects in memory. For example, if you have CoreData database, and you now for sure, that number of items is not big, you can choose not to use CoreDataStorage and NSFetchedResultsController. You can fetch all required models, and store them in MemoryStorage.

### RealmStorage

`RealmStorage` is a class, that is meant to be used with [realm.io](https://realm.io) databases. To use `RealmStorage` with `DTCollectionViewManager`, add following line to your Podfile:

```ruby
    pod 'DTModelStorage/Realm'
```

If you are using Carthage, `RealmStorage` will be automatically built along with `DTModelStorage`.

## Reacting to events

Event system in DTCollectionViewManager 5 allows you to react to `UICollectionViewDelegate`, `UICollectionViewDataSource` and `UICollectionViewDelegateFlowLayout` events based on view and model types, completely bypassing any switches or ifs when working with UICollectionView API. For example:

```swift
manager.didSelect(PostCell.self) { cell,model,indexPath in
  print("Selected PostCell with \(model) at \(indexPath)")
}
```

**Important**

All events with closures are stored on `DTCollectionViewManager` instance, so be sure to declare [weak self] in capture lists to prevent retain cycles.

### Event types

There are two types of events:

1. Event where we have underlying view at runtime
1. Event where we have only data model, because view has not been created yet.

In the first case, we are able to check view and model types, and pass them into closure. In the second case, however, if there's no view, we can't make any guarantees of which type it will be, therefore it loses view generic type and is not passed to closure. These two types of events have different signature, for example:

```swift
// Signature for didSelect event
// We do have a cell, when UICollectionView calls "collectionView(_:didSelectItemAt:)" method
open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UICollectionViewCell


// Signature for sizeForCell(withItem:) event
// When UICollectionView calls "collectionView(_:layout:sizeForItemAt:)" method, cell is not created yet, so closure contains two arguments instead of three, and there are no guarantees made about cell type, only model type
open func sizeForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat)
```

It's also important to understand, that event system is implemented using `responds(to:)` method override and is working on the following rules:

* If `DTCollectionViewManageable` is implementing delegate method, `responds(to:)` returns true
* If `DTCollectionViewManager` has events tied to selector being called, `responds(to:)` also returns true

What this approach allows us to do, is configuring UICollectionView knowledge about what delegate method is implemented and what is not. For example, `DTCollectionViewManager` is implementing `collectionView(_:layout:sizeForItemAt:)` method, however if you don't call `sizeForCell(withItem:_:)` method, you are safe to use self-sizing cells in UICollectionView. While **27** delegate methods are implemented, only those that have events or are implemented by delegate will be called by `UICollectionView`.

`DTCollectionViewManager` has the same approach for handling each delegate and datasource method:

* Try to execute event, if cell and model type satisfy requirements
* Try to call delegate or datasource method on `DTCollectionViewManageable` instance
* If two previous scenarios fail, fallback to whatever default `UICollectionView` has for this delegate or datasource method

### Events list

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

## Advanced usage

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

### Customizing UICollectionView updates

`DTCollectionViewManager` uses `CollectionViewUpdater` class by default. However for `CoreData` you might want to tweak UI updating code. For example, when reloading cell, you might want animation to occur, or you might want to silently update your cell. This is actually how [Apple's guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html) for `NSFetchedResultsController` suggests you should do. Another interesting thing it suggests that .Move event reported by NSFetchedResultsController should be animated not as a move, but as deletion of old index path and insertion of new one.

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

These are all default options, however you might implement your own implementation of `CollectionViewUpdater`, the only requirement is that object needs to conform to `StorageUpdating` protocol. This gives you full control on how and when `DTCollectionViewManager` will update `UICollectionView`.

### Customizing mapping resolution

There can be cases, where you might want to customize mappings based on some criteria. For example, you might want to display model in several kinds of cells:

```swift
class FoodTextCell: UICollectionViewCell, ModelTransfer {
    func update(with model: Food) {
        // Text representation
    }
}

class FoodImageCell: UICollectionViewCell, ModelTransfer {
    func update(with model: Food) {
        // Photo representation
    }
}

manager.register(FoodTextCell.self)
manager.register(FoodImageCell.self)
```

If you don't do anything, FoodTextCell mapping will be selected as first mapping, however you can adopt `ViewModelMappingCustomizing` protocol to adjust your mappings:

```swift
extension PostViewController : ViewModelMappingCustomizing {
    func viewModelMapping(fromCandidates candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
        if let foodModel = model as? Food where foodModel.hasPhoto {
            return candidates.last
        }
        return candidates.first
    }
}
```

### Unregistering mappings

You can unregister cells, headers and footers from `DTCollectionViewManager` and `UICollectionView` by calling:

```swift
manager.unregister(FooCell.self)
manager.unregisterHeader(HeaderView.self)
manager.unregisterFooter(FooterView.self)
manager.unregisterSupplementary(SupplementaryView.self, forKind: "foo")
```

This is equivalent to calling collection view register methods with nil class or nil nib.

### Error reporting

In some cases `DTCollectionViewManager` will not be able to create cell, header or footer view. This can happen when passed model is nil, or mapping is not set. By default, 'fatalError' method will be called and application will crash. You can improve crash logs by setting your own error handler via closure:

```swift
manager.viewFactoryErrorHandler = { error in
    // DTCollectionViewFactoryError type
    print(error.description)
}
```

## ObjectiveC support

`DTCollectionViewManager` is heavily relying on Swift protocol extensions, generics and associated types. Enabling this stuff to work on Objective-c right now is not possible. Because of this DTCollectionViewManager 4 and greater only supports building from Swift. If you need to use Objective-C, you can use [latest Objective-C compatible version of `DTCollectionViewManager`](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/3.3.0).

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTCollectionViewManager)!

## Running example project

```bash
pod try DTCollectionViewManager
```

## Thanks

* [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.
* [Michael Fey](https://github.com/MrRooni) for providing insight into NSFetchedResultsController updates done right.
* [Nickolay Sheika](https://github.com/hawk-ukr) for great feedback, that helped shaping 3.0 release.
* [Artem Antihevich](https://github.com/sinarionn) for great discussions about Swift generics and type capturing.
