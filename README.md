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
## Workflow

Here are 4 simple steps you need to use DTCollectionViewManager:

1. Your view controller should subclass `DTCollectionViewController`, and set collectionView property.
2. You should have subclasses of `DTCollectionViewCell`.
3. In your viewDidLoad method, call mapping methods to establish relationship between data models and UICollectionViewCells.
4. Add data models to memoryStorage, or use CoreData storage class.

## API quickstart

<table>
<tr><th colspan=2 style="text-align:center;">Key classes</th></tr>
	<tr>
	<td> DTCollectionViewController </td>
	<td>Your UIViewController, that presents collectionView, needs to subclass* this class. This class implements all UICollectionViewDatasource methods.</td>
	</tr>
	<tr>
	<td>DTCollectionViewMemoryStorage</td>
	<td>Class responsible for holding collectionView models. It is used as a default storage by DTCollectionViewManager.</td>
	</tr>
	<tr>
	<td>DTCoreDataStorage</td>
	<td>Class used to display data, using `NSFetchedResultsController`.</td>
	</tr>
	<tr>
	<td>DTSectionModel</td>
	<td> Object, representing section in UICollectionView. Basically has array of objects and array of supplementary models for current section.</td>
	</tr>
<tr><th colspan=2 style="text-align:center;">Protocols</th></tr>
	<tr>
	<td>DTModelTransfer</td>
	<td> Protocol, which methods are used to transfer model to UICollectionViewCell subclass, that will be representing it.</td>
	</tr>
<tr><th colspan=2 style="text-align:center;">Convenience classes (optional)</th></tr>
	<tr>
	<td>DTCollectionViewCell</td>
	<td> UICollectionViewCell subclass, conforming to `DTModelTransfer` protocol. </td>
	</tr>
	<tr>
	<td>DTCollectionReusableView</td>
	<td>UICollectionReusableView subclass, conforming to `DTModelTransfer` protocol.</td>
	</tr>
</table>

## Features

DTCollectionViewManager is built on several important concepts, that allow collection view management to be flexible and clean. 

### Mapping 

Typically, you have UICollectionViewCells, UICollectionReusableViews and your data models, that need to be represented. And every time you need to write method like this:
```objective-c
-(void)configureCell:(UICollectionViewCell *)cell withSomething:(id)something;
```

You'll also will have some NSString reuseIdentifier you will use to dequeue your cells and supplementary views. And you'll also need to register appropriate classes on your UICollectionView instance. 

**DTCollectionViewManager removes all of that**. You will need to call a single method:

```objective-c
[self registerCellClass:[MyCell class] forModelClass:[MyModel class]];
```

or it's supplementary view variant:

```objective-c
[self registerSupplementaryClass:[SupplementaryClass class] 
                         forKind:UICollectionElementKindSectionHeader 
                   forModelClass:[SupplementaryModel class]];
```
And you are done! 

So, how does that work? DTCollectionViewManager uses your cell class as a reuseIdentifier for your cell. Every time data model needs to be displayed, it will automatically create UICollectionViewCell and call a method `-updateWithModel:` on it, which will transfer data model to a cell. Cell is then expected to properly update it's UI, based on data model.

DTCollectionViewManager supports creating cells and supplementary views both from XIBs and storyboards.

### Datasource and UI synchronization

Every time you use UICollectionView in your app, you need to think about two things - data models and their representation. For every datasource change there has to be a method, that updates UI. DTCollectionViewManager simplifies that by having methods to update your datasource only. UICollectionView update methods are called automatically. You can also make any changes manually, if you choose to. 

### Custom storage classes

DTCollectionViewManager 2.0 introduces support for custom data storage classes. Current storage classes have been extracted to [separate project](https://github.com/DenHeadless/DTModelStorage) and are used as a dependency. Two data storage classes are supported by default.

##### Memory storage 

Memory storage is basically array of section objects, which contain array of objects and any supplementary models for current section. It is used by default and there's convenience method to retrieve it:

```objective-c
DTCollectionViewMemoryStorage * storage = [self memoryStorage];
```

To add, delete and apply other operations, take a look here: [DTMemoryStorage methods](https://github.com/DenHeadless/DTModelStorage/blob/master/README.md#adding-items)

In most cases, adding items to memory storage is as simple as calling:

```objective-c
- (void)addItem:(NSObject *)item;
- (void)addItems:(NSArray *)items toSection:(NSInteger)sectionNumber;
```

##### Core data storage 

Core data storage is a storage class, that is used to interact with NSFetchedResultsController. It's actually extremely easy to use:

```objective-c
NSFetchedResultsController * controller = ...;
self.dataStorage = [DTCoreDataStorage storageWithFetchResultsController:controller];
```

And that's it! 

DTCollectionViewManager will display models, based on info that NSFetchedResultsController has. Every update in CoreData database will be properly animated, using info provided by NSFetchedResultsControllerDelegate methods.

### UICollectionView - fixed!

UICollectionView has a great API, that provides enourmous possiibilities. Unfortunately, sometimes it is very fragile. It has some iOS 6 issues, some iOS 7 issues, and some issues, that persist in both iOS releases. Most important of them, if of course, [insertion of the first item in section](http://openradar.appspot.com/12954582). 

DTCollectionViewManager tries very hard to eliminate those. And every issue i know of, is fixed in 2.0 release. If something is working not as expected - please [open an issue on GitHub](https://github.com/DenHeadless/DTCollectionViewManager/issues). Project also has good unit test coverage, which is very helpful.
	
## Using storyboards

To use storyboard collection view, set reuseIdentifier for collection cell or reusable header/footer with the name of your cell, header or footer class. Call `registerCellClass:forModelClass:` just as for xib registration.

You can also take a look at example, which contains storyboard colllection view with prototyped cell, header, and footer.

## Foundation class clusters mapping

Most of the time you will have your own data models for cells. However, sometimes it's more convenient to use Foundation types, such as NSString, NSNumber, etc. For example, if you have supplementary view - header, that does not have any information except for it's title - you'll probably want to use NSString as its model. Mutable versions are also supported. 
 
`DTCollectionViewController` supports mapping of following Foundation types:
 
 * NSString
 * NSNumber
 * NSDictionary
 * NSArray
 
## Searching in UICollectionView

### DTCollectionViewMemoryStorage

Set UISearchBar's delegate property to your `DTCollectionViewController` subclass. 	

Call memoryStorage setSearchingBlock:forModelClass: to determine, whether model of passed class should show for current search criteria. This method can be called as many times as you need.
```objective-c
[self.memoryStorage setSearchingBlock:^BOOL(id model, NSString *searchString, NSInteger searchScope, DTSectionModel *section) 
	{
        Example * example  = model;
        if ([example.text rangeOfString:searchString].location == NSNotFound)
        {
            return NO;
        }
        return YES;
    } forModelClass:[Example class]];
```

Searching data storage will be created automatically for current search, and it will be used as a datasource for UICollectionView.

`DTCollectionViewController` will automatically respond to UISearchBar events and update UICollectionView accordingly. Take a look at provided example.

### DTCoreDataStorage

Subclass `DTCoreDataStorage` and implement single method 
```objective-c
- (instancetype)searchingStorageForSearchString:(NSString *)searchString
                                  inSearchScope:(NSInteger)searchScope;
```	

You will need to provide a storage with NSFetchedResultsController and appropriate NSPredicate. Model will also need to implement `DTModelSearching` protocol method, just like with memory storage.

## Installation

Simplest option is to use [CocoaPods](http://www.cocoapods.org):

	pod 'DTCollectionViewManager', '~> 2.6.1'
	
## Requirements

- iOS 6,7
- ARC
	
## Documentation

[Cocoadocs](http://cocoadocs.org/docsets/DTCollectionViewManager)

## Thanks

[Ash Furrow](https://github.com/AshFurrow) for his amazing investigative [work on UICollectionView updates](https://github.com/AshFurrow/UICollectionView-NSFetchedResultsController).

[Alexey Belkevich](https://github.com/belkevich) for continuous testing and contributing to the project.

