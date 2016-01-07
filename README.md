![Build Status](https://travis-ci.org/DenHeadless/DTCollectionViewManager.png?branch=master) &nbsp;
[![codecov.io](http://codecov.io/github/DenHeadless/DTCollectionViewManager/coverage.svg?branch=master)](http://codecov.io/github/DenHeadless/DTCollectionViewManager?branch=master)
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTCollectionViewManager/badge.svg) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTCollectionViewManager/badge.svg) &nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)
DTCollectionViewManager 4
=======================

> This is a sister-project for [DTTableViewManager](https://github.com/DenHeadless/DTTableViewManager) - great tool for UITableView management, built on the same principles.

Powerful protocol-oriented UICollectionView management framework, written in Swift 2.

## Features

- [x] Powerful mapping system between data models and cells, headers and footers
- [x] Support for all Swift types - classes, structs, enums, tuples
- [x] Support for protocols and subclasses as data models
- [x] Views created from code, XIB, or storyboard
- [x] Flexible Memory/CoreData/Custom storage options
- [x] Support for Realm.io databases
- [x] Automatic datasource and interface synchronization.
- [x] Automatic XIB registration and dequeue
- [x] No type casts required
- [x] No need to subclass
- [x] Can be used with UICollectionViewController, or UIViewController with UICollectionView, or any other class, that contains UICollectionView

## Requirements

* XCode 7 and higher
* iOS 8 and higher / tvOS 9.0 and higher
* Swift 2

## Installation

[CocoaPods](http://www.cocoapods.org):

    pod 'DTCollectionViewManager', '~> 4.5.0'

[Carthage](https://github.com/Carthage/Carthage):

    github "DenHeadless/DTCollectionViewManager"  ~> 4.5.0

After running `carthage update` drop DTCollectionViewManager.framework and DTModelStorage.framework to XCode project embedded binaries.

## Quick start

`DTCollectionViewManager` framework has two parts - core framework, and storage classes. Import them both to your view controller class to start:

```swift
import DTCollectionViewManager
import DTModelStorage
```

The core object of a framework is `DTCollectionViewManager`. Declare your class as `DTCollectionViewManageable`, and it will be automatically injected with `manager` property, that will hold an instance of `DTCollectionViewManager`.

First, make sure your UICollectionView outlet is wired to your class.

**Important** Your UICollectionView outlet should be declared as optional:

```swift
  @IBOutlet weak var collectionView: UICollectionView?
```

Call `startManagingWithDelegate:` to initiate UICollectionView management:

```swift
    manager.startManagingWithDelegate(self)
```

Let's say you have an array of Posts you want to display in UICollectionView. To quickly show them using DTCollectionViewManager, here's what you need to do:

* Create UICollectionViewCell subclass, let's say PostCell. Adopt ModelTransfer protocol

```swift
class PostCell : UICollectionViewCell, ModelTransfer
{
	func updateWithModel(model: Post)
	{
		// Fill your cell with actual data
	}
}
```

* Call registration methods on your `DTCollectionViewManageable` instance

```swift
	manager.registerCellClass(PostCell)
```

ModelType will be automatically gathered from your `PostCell`. If you have a PostCell.xib file, it will be automatically registered for PostCell. If you have a storyboard with PostCell, set it's reuseIdentifier to be identical to class - "PostCell".

* Add your posts!

```swift
	manager.memoryStorage.addItems(posts)
```

That's it! It's that easy!

## Mapping and registration

* `registerCellClass:`
* `registerNibNamed:forCellClass:`
* `registerHeaderClass:`
* `registerNibNamed:forHeaderClass:`
* `registerFooterClass:`
* `registerNibNamed:forFooterClass:`
* `registerSupplementaryClass:forKind:`
* `registerNibNamed:forSupplementaryClass:forKind:`
* `registerNiblessSupplementaryClass:forKind:`

For more detailed look at mapping in DTCollectionViewManager, check out dedicated *[Mapping wiki page](https://github.com/DenHeadless/DTCollectionViewManager/wiki/Mapping-and-registration)*.

## Data models

Starting from [4.4.0 release](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.4.0), `DTCollectionViewManager` supports all Swift and Objective-C types as data models. This also includes protocols and subclasses. So now this works:

```swift
protocol Food {}
class Apple : Food {}
class Carrot: Food {}

class FoodCollectionViewCell : UICollectionViewCell, ModelTransfer {
    func updateWithModel(model: Food) {
        // Display food in a cell
    }
}
manager.registerCellClass(FoodCollectionViewCell)
manager.memoryStorage.addItems([Apple(),Carrot()])
```

Mappings are resolved simply by calling `is` type-check. In our example Apple is Food and Carrot is Food, so mapping will work.

### Customizing mapping resolution

There can be cases, where you might want to customize mappings based on some criteria. For example, you might want to display model in several kinds of cells:

```swift
class FoodTextCell: UICollectionViewCell, ModelTransfer {
    func updateWithModel(model: Food) {
        // Text representation
    }
}

class FoodImageCell: UICollectionViewCell, ModelTransfer {
    func updateWithModel(model: Food) {
        // Photo representation
    }
}

manager.registerCellClass(FoodTextCell)
manager.registerCellClass(FoodImageCell)
```

If you don't do anything, FoodTextCell mapping will be selected as first mapping, however you can adopt `DTViewModelMappingCustomizable` protocol to adjust your mappings:

```swift
extension PostViewController : DTViewModelMappingCustomizable {
    func viewModelMappingFromCandidates(candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
        if let foodModel = model as? Food where foodModel.hasPhoto {
            return candidates.last
        }
        return candidates.first
    }
}
```

## DTModelStorage

[DTModelStorage](https://github.com/DenHeadless/DTModelStorage/) is a framework, that provides storage classes for `DTCollectionViewManager`. By default, `storage` property on `DTCollectionViewManager` holds a `MemoryStorage` instance.

### MemoryStorage

`MemoryStorage` is a class, that manages UICollectionView models in memory. It has methods for adding, removing, replacing, reordering collection view models etc. You can read all about them in [DTModelStorage repo](https://github.com/DenHeadless/DTModelStorage#memorystorage). Basically, every section in `MemoryStorage` is an array of `SectionModel` objects, which itself is an object, that contains optional header and footer models, and array of collection items.

### NSFetchedResultsController and CoreDataStorage

`CoreDataStorage` is meant to be used with NSFetchedResultsController. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UICollectionView, is create CoreDataStorage object and set it on your `storage` property of `DTCollectionViewManager`.

Keep in mind, that MemoryStorage is not limited to objects in memory. For example, if you have CoreData database, and you now for sure, that number of items is not big, you can choose not to use CoreDataStorage and NSFetchedResultsController. You can fetch all required models, and store them in MemoryStorage.

### RealmStorage

`RealmStorage` is a class, that is meant to be used with [realm.io](https://realm.io) databases. To use `RealmStorage` with `DTCollectionViewManager`, add following line to your Podfile:

```ruby
    pod 'DTModelStorage/Realm'
```

If you are using Carthage, `RealmStorage` will be automatically built along with `DTModelStorage`.

## Subclassing storage classes

For in-depth look at how subclassing storage classes can improve your code base, read [this article](https://github.com/DenHeadless/DTTableViewManager/wiki/Extracting-logic-into-storage-subclasses) on wiki.

## Reacting to events

### Method pointers

There are two types of events reaction. The first and recommended one is to pass method pointers to `DTCollectionViewManager`. For example, selection:

```swift
manager.cellSelection(PostViewController.selectedPost)

func selectedPost(cell: PostCell, post: Post, indexPath: NSIndexPath) {
  // Do something with Post
}
```

`DTCollectionViewManager` automatically breaks retain cycles, that can happen when you pass method pointers around. There's no need to worry about [weak self] stuff.

There are also methods for configuring cells, headers and footers:

```swift
manager.cellConfiguration(PostViewController.configurePostCell)
manager.headerConfiguration(PostViewController.configurePostsHeader)
manager.footerConfiguration(PostViewController.configurePostsFooter)
manager.supplementaryConfiguration(kind: UICollectionElementKindSectionHeader, PostViewController.configurePostsSupplementary)
```

And of course, you can always use dynamicType instead of directly referencing type name:

```swift
manager.cellSelection(self.dynamicType.selectedPost)
```

Another way of dealing with events, is registrating closures.

**Important**

Unlike methods with method pointers, all events with closures are stored on `DTCollectionViewManager` instance, so be sure to declare [weak self] in capture lists to prevent retain cycles.

### Selection

 Instead of reacting to cell selection at UICollectionView NSIndexPath, `DTCollectionViewManager` allows you to react when user selects concrete model:

```swift
  manager.whenSelected(PostCell.self) { postCell, post, indexPath in
      print("Selected \(post) in \(postCell) at \(indexPath)")
  }
```

Thanks to generics, `postCell` and `post` are already a concrete type, there's no need to check types and cast. There' also a shortcut to registration and selection method:

```swift
  manager.registerCellClass(PostCell.self, whenSelected: { postCell, post, indexPath in })
```

### Configuration

Although in most cases your cell can update it's UI with model inside `updateWithModel:` method, sometimes you may need to additionally configure it from controller. There are four events you can react to:

```swift
  manager.configureCell(PostCell.self) { postCell, post, indexPath in }
  manager.configureHeader(PostHeader.self) { postHeader, postHeaderModel, sectionIndex in }
  manager.configureFooter(PostFooter.self) { postFooter, postFooterModel, sectionIndex in }
  manager.configureSupplementary(PostSupplementary.self) { postSupplementary, postSupplementaryModel, sectionIndex in}
```

Headers are supplementary views of type `UICollectionElementKindSectionHeader`, and footers are supplementary views of type `UICollectionElementKindSectionFooter`.

### Content updates

Sometimes it's convenient to know, when data is updated, for example to hide UICollectionView, if there's no data. Conform to `DTCollectionViewContentUpdatable` protocol and implement one of the following methods:

```swift
extension PostsViewController: DTCollectionViewContentUpdatable {
  func beforeContentUpdate() {

  }

  func afterContentUpdate() {

  }
}
```

## UICollectionViewDelegate and UICollectionViewDatasource

`DTCollectionViewManager` serves as a datasource and the delegate to `UICollectionView`. However, it implements only some of UICollectionViewDelegate and UICollectionViewDatasource methods, other methods will be redirected to your controller, if it implements it.

## Convenience model getters

There are several convenience model getters, that will allow you to get data model from storage classes. Those include cell, header or footer class types to gather type information and being able to return model of correct type. Again, no need for type casts.

```swift
  let post = manager.itemForCellClass(PostCell.self, atIndexPath: indexPath)
  let postHeaderModel = manager.itemForHeaderClass(PostHeaderClass.self, atSectionIndex: sectionIndex)
  let postFooterModel = manager.itemForFooterClass(PostFooterClass.self, atSectionIndex: sectionIndex)
```

There's also convenience getter, that will allow you to get model from visible `UICollectionViewCell`.

```swift
  let post = manager.itemForVisibleCell(postCell)
```

## Error reporting

In some cases `DTCollectionViewManager` will not be able to create cell or supplementary view. This can happen when passed model is nil, or mapping is not set. By default, 'fatalError' method will be called and application will crash. You can improve crash logs by setting your own error handler via closure:

```swift
manager.viewFactoryErrorHandler = { error in
    // DTCollectionViewFactoryError type
    print(error.description)
}
```

## ObjectiveC

`DTCollectionViewManager` is heavily relying on Swift 2 protocol extensions, generics and associated types. Enabling this stuff to work on objective-c right now is not possible. Because of this DTCollectionViewManager 4 does not support usage in objective-c. If you need to use objective-c, you can use [latest compatible version of `DTCollectionViewManager`](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/3.2.0).

## Documentation

You can view documentation online or you can install it locally using [cocoadocs](http://cocoadocs.org/docsets/DTCollectionViewManager)!

Also check out [wiki page](https://github.com/DenHeadless/DTCollectionViewManager/wiki) for some information on DTCollectionViewManager internals.

## Running example project

```
pod try DTCollectionViewManager
```

## Thanks

* [Ash Furrow](https://github.com/AshFurrow) for his amazing investigative [work on UICollectionView updates](https://github.com/AshFurrow/UICollectionView-NSFetchedResultsController).
* [Alexey Belkevich](https://github.com/belkevich) for continuous testing and contributing to the project.
* [Artem Antihevich](https://github.com/sinarionn) for great discussions about Swift generics and type capturing.
