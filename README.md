![Build Status](https://travis-ci.org/DenHeadless/DTCollectionViewManager.png?branch=master) &nbsp;
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTCollectionViewManager/badge.svg) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTCollectionViewManager/badge.svg) &nbsp;
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)
DTCollectionViewManager
=======================

> This is a sister-project for [DTTableViewManager](https://github.com/DenHeadless/DTTableViewManager) - great tool for UITableView management, built on the same principles.

Try it out! 

```bash
pod try DTCollectionViewManager
```

## Features

* Powerful mapping system between data models and collection view cells and supplementary views
* Automatic datasource and interface synchronization.
* Support for creating cells from XIBs or storyboards.
* Easy UICollectionView search 
* Core data / NSFetchedResultsController support
* Swift support

## Quick start

Let's say you have an array of Kittens you want to display in UICollectionView. To quickly show them using DTCollectionViewManager, here's what you need to do:

Subclass DTCollectionViewController, create xib, or storyboard with your view controller, wire up collectionView outlet. Add following code to viewDidLoad:

```objective-c
[self registerCellClass:[KittenCell class] forModelClass:[Kitten class]];
[self.memoryStorage addItems:kittens];
```
or in Swift:
```swift
self.registerCellClass(KittenCell.self, forModelClass:Kitten.self)
self.memoryStorage().addItems(kittens)
```

Subclass DTCollectionViewCell, and implement updateWithModel method
```objective-c
-(void)updateWithModel:(id)model
{
    Kitten * kitten = model;
    self.kittenImageView.image = kitten.image;
}
```
or in Swift:
```swift
func updateWithModel(model: AnyObject!)
{
    let kitten = model as Kitten
    self.kittenImageView.image = kitten.image
}
```

That's it! For more detailed look at available API - **[API quickstart](https://github.com/DenHeadless/DTCollectionViewManager/wiki/API-quickstart)** page on wiki.

### Mapping 

Typically, you have UICollectionViewCells, UICollectionReusableViews and your data models, that need to be represented. And every time you need to write method like this:
```objective-c
-(void)configureCell:(UICollectionViewCell *)cell withSomething:(id)something;
```

You'll also will have some NSString reuseIdentifier you will use to dequeue your cells and supplementary views. And you'll also need to register appropriate classes on your UICollectionView instance. 

DTCollectionViewManager removes all of that. You will need to call a single method:

```objective-c
[self registerCellClass:[MyCell class] forModelClass:[MyModel class]];
```

or it's supplementary view variant:

```objective-c
[self registerHeaderClass:[SupplementaryView class] 
            forModelClass:[SupplementaryModel class]];
```
And you are done! 

For more detailed look at mapping in DTCollectionViewManager, check out dedicated *[Mapping wiki page](https://github.com/DenHeadless/DTCollectionViewManager/wiki/Mapping-and-registration)*.

## Managing collection items

Storage classes for DTCollectionViewManager have been moved to [separate repo](https://github.com/DenHeadless/DTModelStorage). Two data storage classes are provided - memory and core data storage. 

#### Memory storage

`DTMemoryStorage` encapsulates storage of collection view data models in memory. It's basically NSArray of `DTSectionModel` objects, which contain array of items and supplementary models for current section.

**You can take a look at all provided methods for manipulating items here: [DTMemoryStorage methods](https://github.com/DenHeadless/DTModelStorage/blob/master/README.md#adding-items)**

DTCollectionViewManager adds several methods to `DTMemoryStorage`, that are specific to UICollectionView. Take a look at them here: **[DTMemoryStorage additions](https://github.com/DenHeadless/DTCollectionViewManager/wiki/DTMemoryStorage-additions)**

#### NSFetchedResultsController and DTCoreDataStorage

`DTCoreDataStorage` is meant to be used with NSFetchedResultsController. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UICollectionView, is create DTCoreDataStorage object and set it on your DTCollectionViewController subclass.

```objective-c
self.dataStorage = [DTCoreDataStorage storageWithFetchResultsController:controller];
```

**Important** Keep in mind, that DTMemoryStorage is not limited to objects in memory. For example, if you have CoreData database, and you now for sure, that number of items is not big, you can choose not to use DTCoreDataStorage and NSFetchedResultsController. You can fetch all required models, and store them in DTMemoryStorage, just like you would do with NSObject subclasses.

## Search

DTCollectionViewManager has a built-in search system, that is easy to use and flexible. Read all about it in a dedicated **[Implementing search](https://github.com/DenHeadless/DTCollectionViewManager/wiki/Implementing-search)** wiki page.

## UICollectionView - fixed!

UICollectionView has a great API, that provides enourmous possiibilities. Unfortunately, sometimes it is very fragile. Up until iOS 8, it has some issues, that could lead to crashes, if you "hold it wrong". Most important of them, if of course, [insertion of the first item in section](http://openradar.appspot.com/12954582). 

DTCollectionViewManager tries very hard to eliminate those. And every issue i know of, is fixed in 3.0 release. If something is working not as expected - please [open an issue on GitHub](https://github.com/DenHeadless/DTCollectionViewManager/issues). Project also has good unit test coverage, which is very helpful.
	
## Installation

Simplest option is to use [CocoaPods](http://www.cocoapods.org):

	pod 'DTCollectionViewManager', '~> 3.1.0'
	
## Requirements

* XCode 6.3 and higher
* iOS 7,8
* ARC
	
## Documentation

[Cocoadocs](http://cocoadocs.org/docsets/DTCollectionViewManager)

Also check out [wiki page](https://github.com/DenHeadless/DTCollectionViewManager/wiki) for lot's of information on DTCollectionViewManager internals and best practices.

## Thanks

[Ash Furrow](https://github.com/AshFurrow) for his amazing investigative [work on UICollectionView updates](https://github.com/AshFurrow/UICollectionView-NSFetchedResultsController).

[Alexey Belkevich](https://github.com/belkevich) for continuous testing and contributing to the project.
