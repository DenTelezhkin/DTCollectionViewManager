![Build Status](https://travis-ci.org/DenHeadless/DTCollectionViewManager.png?branch=master,development) &nbsp;
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTCollectionViewManager/badge.svg) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTCollectionViewManager/badge.svg) &nbsp;
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)
DTCollectionViewManager
=======================

> This is a sister-project for [DTTableViewManager](https://github.com/DenHeadless/DTTableViewManager) - great tool for UITableView management, built on the same principles.


### Features

DTCollectionViewManager is built on several important concepts, that allow collection view management to be flexible and clean. 

#### Mapping 

Every time you use UICollectionView, you tend to have UICollectionViewCells, UICollectionReusableViews and your data models, that need to be represented. And every time you need to write method like this:
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
[self registerSupplementaryClass:[SupplementaryClass class] forKind:UICollectionViewElementHeader forModelClass:[SupplementaryModel class]];
```
And you are done! So, how does that work? DTCollectionViewManager uses your data model class as a reuseIdentifier for your cell. Every time data model needs to be displayed, it will create UICollectionViewCell and call a method -updateWithModel on it, which will transfer data model to a cell. Cell is then expected to properly update it's UI, based on data model.

DTCollectionViewmanager supports creating cells and supplementary views both from XIBs and storyboards.

#### Datasource and UI synchronization

Every time you use UICollectionView in your app, you need to think about two things - data models and their representation. For every datasource change there has to be a method, that updates UI. DTCollectionViewManager simplifies that by having methods to update your datasource only. UICollectionView update methods are called automatically. You can also make any changes manually, if you choose to. 

#### Custom storage classes

DTCollectionViewManager 2.0 introduces support for custom data storage classes. Current storage classes have been extracted to separate project and are used as a dependency. You can take a look at them here:
[DTModelStorage repo](https://github.com/DenHeadless/DTModelStorage)

##### Memory storage 

Out of the box there is support for memory storage and core data storage. Memory storage is basically array of section objects, which contain array of objects and any supplementary models for current section. Core data storage 

* Powerful and clean mapping system between data models and UICollectionView cells, supplementary views 
* Support for creating interface from XIBs and storyboards
* Automatic datasource and interface synchronization
* Dramatic decrease of code amount needed for UICollectionView implementation
* Good unit test coverage

## Requirements

- iOS 6,7
- ARC

## Workflow

Here are 4 simple steps you need to use DTCollectionViewManager:

1. Your view controller should subclass DTCollectionViewController, and set collectionView, delegate and datasource properties to self.
2. You should have subclasses of UICollectionViewCell, that implement DTCollectionViewModelTransfer protocol.
3. In your viewDidLoad method, call mapping methods to establish relationship between data models and UICollectionViewCells.
4. Add your data models!

## Mapping

Every mapping method will automatically check for existance of xib with the same name. If it does exist - nib will be registered for creating cells. If not - it will be assumed, that storyboard registers cell for us. When collection view will need to present content, cells will be created using dequeueReusableCellWithReuseIdentifier:forIndexPath: method. Then every cell will get called with updateWithModel: method, passing data model to cell, so it could present it's data.

Mapping cells:

```objective-c
[self registerCellClass:[Cell class] forModelClass:[Model class]];
```

Mapping supplementary views:
```objective-c
[self registerSupplementaryClass:[SupplementaryClass class] 
						  forKind:UICollectionElementKindSectionHeader
                   forModelClass:[Model class]];
```

## Managing collection items

##### Adding items

```objective-c
[self addCollectionItem:model];
[self addCollectionItem:model toSection:1];
[self addCollectionItems:@[model1,model2]];
[self addCollectionItems:@[model1,model2] toSection:0];
```

##### Removing items

```objective-c
[self removeCollectionItem:model];
[self removeCollectionItemAtIndexPath:indexPath];
[self removeCollectionItems:@[model1,model2]];
[self removeCollectionItemsAtIndexPaths:@[index1,index2]];
[self removeAllCollectionItems];
```	

#### Move, insert, replace

```objective-c
[self insertItem:model atIndexPath:indexPath];
[self moveItem:model toIndexPath:indexPath];
[self replaceItem:model withItem:newModel];
```

#### Managing sections

```objective-c
[self moveSection:fromSection toSection:toSection];
[self deleteSections:indexSet];
```	

#### Search 

```objective-c
[self numberOfSections];
[self numberOfCollectionItemsInSection:2];
[self collectionItemAtIndexPath:indexPath];
```	
## Using storyboards

To use storyboard collection view, set reuseIdentifier for collection cell or reusable header/footer with the name of your model class. Call registerCellClass:forModelClass: just as for xib registration.

You can also take a look at example, which contains storyboard colllection view with prototyped cell, header, and footer.


## Installation

Simplest option is to use [CocoaPods](http://www.cocoapods.org):

	pod 'DTCollectionViewManager', '~> 1.1.0'
	
## Documentation

[Cocoadocs](http://cocoadocs.org/docsets/DTCollectionViewManager)

## Example

Take a look at Example folder in repo.

### Assertion in -[UICollectionViewData indexPathForItemAtGlobalIndex:]

There is a bug in UICollectionView, that prevents insertItemsAtIndexPaths: to work correctly. DTCollectionViewManager tries to handle this gracefully, and at least not crash an application. However, collection view cells may be displayed incorrectly. 

Workaround: instead of using addCollectionItems methods, add them manually and call reloadData. 
This will save you 99% of the time. 
Example:

```objective-c
    NSMutableArray * section = (NSMutableArray *)[self itemsArrayForSection:0];
    [section removeAllObjects];
    [section addObjectsFromArray:@[<items>]];
    [self.collectionView reloadData];
```

## Foundation class clusters mapping

Most of the time you will have your own data models for cells. However, sometimes it's more convenient to use Foundation types, such as NSString, NSNumber, etc. For example, if you have supplementary view - header, that does not have any information except for it's title - you'll probably want to use NSString as its model. Mutable versions are also supported. 
 
 DTCollectionViewController supports mapping of following Foundation types:
 
 * NSString
 * NSNumber
 * NSDictionary
 * NSArray


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/DenHeadless/dtcollectionviewmanager/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

