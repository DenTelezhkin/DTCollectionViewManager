//
//  DTCollectionViewController.h
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 6/19/12.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/**
 `DTCollectionViewController` manages all `UICollectionView` datasource methods and provides API for mapping your data models to UICollectionViewCells. It also contains storage object, that is responsible for providing data models.
 
 ## Setup
 
 # General steps
 - You should have custom `UICollectionViewCell` subclasses that manage cell layout, using given data model (or `DTCollectionViewCell`, which is convenience UICollectionView subclass, that conforms to `DTModelTransfer` protocol)
 - Every cell class should be mapped to model class using mapping methods.
 - `UICollectionView` datasource and delegate is your `DTCollectionViewController` subclass.
 
 ## Managing collection items
 
 Starting with 2.0, storage classes have been moved to separate project - DTModelStorage. Basically, every change in data storage object is transferred to current controller and automatically properly animated. DTMemoryStorage is a class used by default, you can retrieve it's instance by calling '-memoryStorage' method.
 
 ## Mapping
 
 Use `registerCellClass:forModelClass` for mapping cell class to model. 'DTCollectionViewController' will automatically check, if there's a nib with the same name as cellClass. If it is - this nib is registered for modelClass. If there's no nib - cellClass will be registered for modelClass. Cells will be created using `dequeueReusableCellWithReuseIdentifier:forIndexPath:` method.
 
 For mapping supplementary views, use `registerSupplementaryClass:forKind:forModelClass:` method.
 
 Before executing mapping methods, make sure that collectionView property is set and collectionView is created. Good spot to call mapping methods is viewDidLoad method.
 
 ## Search
 
 Search implementation depends on what data storage you use. In both cases it's recommended to use this class as UISearchBarDelegate. Then searching data storage will be created automatically for every change in UISearchBar.
 
 # DTMemoryStorage
 
 Call memoryStorage setSearchingBlock:forModelClass: to determine, whether model of passed class should show for current search criteria. This method can be called as many times as you need.
 
 # DTCoreDataStorage
 
 Subclass DTCoreDataStorage and implement single method: -searchingStorageForSearchString:inSearchScope:. You will need to provide a storage with NSFetchedResultsController and appropriate NSPredicate.
 
 ## Foundation class clusters mapping
 
 Most of the time you will have your own data models for cells. However, sometimes it's more convenient to use Foundation types, such as NSString, NSNumber, etc. For example, if you have supplementary view - header, that does not have any information except for it's title - you'll probably want to use NSString as its model. Mutable versions are also supported. 
 
 DTCollectionViewController supports mapping of following Foundation types:
  - NSString
  - NSNumber
  - NSDictionary
  - NSArray
 */

#import "DTMemoryStorage+DTCollectionViewManagerAdditions.h"
#import "DTCollectionViewStorageUpdating.h"

@interface DTCollectionViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,DTCollectionViewStorageUpdating>

///---------------------------------------
/// @name Properties
///---------------------------------------

/**
 
 Collection view that will present your data models.
 */
@property (nonatomic,retain) IBOutlet UICollectionView * collectionView;

/*
 Property to store UISearchBar, attached to your UITableView. Attaching it to this property is completely optional.
 */
@property (nonatomic, retain) IBOutlet UISearchBar * searchBar;

/**
 Storage object, used as a datasource for collection view models.
 */

@property (nonatomic, strong) id <DTStorage> storage;

/**
 Searching data storage object. It will be created automatically, responding to changes in UISearchBar, or after method filterTableItemsForSearchString:inScope: is called.
 */

@property (nonatomic, strong) id <DTStorage> searchingStorage;

/**
 Convenience method, that allows retrieving memory storage. If data storage class is different than DTMemoryStorage, this method will return nil.
 
 @return memory storage object
 */

-(DTMemoryStorage *)memoryStorage;

///---------------------------------------
/// @name Mapping
///---------------------------------------

/**
 This method is used to register mapping from model class to cell class. It will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class.
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to cellClass.
 
 @discussion This is the designated mapping method. Best place to call it - in viewDidLoad method.
 
 */
-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;

/**
 This method is used to register mapping from model class to cell class with custom nib name.
 
 @param nibName Name of the nib file with cell
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to cellClass.
 */
-(void)registerNibNamed:(NSString *)nibName forCellClass:(Class)cellClass forModelClass:(Class)modelClass;

/**
 This method registers `supplementaryClass` for UICollectionView supplementary `kind`. `supplementaryClass` should be a UICollectionReusableView subclass, conforming to `DTModelTransfer` protocol. xib file for supplementary class with `supplementaryClass` name is automatically detected if it exists. 
 
 @param supplementaryClass UICollectionReusableView subclass to be mapped for `modelClass`.
 
 @param kind UICollectionView supplementary view kind.
 
 @param modelClass modelClass to be mapped to `supplementaryClass`
 
 */
-(void)registerSupplementaryClass:(Class)supplementaryClass
                          forKind:(NSString *)kind
                    forModelClass:(Class)modelClass;

/**
 This method registers `supplementaryClass` for UICollectionView supplementary `kind`. `supplementaryClass` should be a UICollectionReusableView subclass, conforming to `DTModelTransfer` protocol.
 
 @param nibName name of the nib file to be used
 
 @param supplementaryClass UICollectionReusableView subclass to be mapped for `modelClass`.
 
 @param kind UICollectionView supplementary view kind.
 
 @param modelClass modelClass to be mapped to `supplementaryClass`
 
 */
-(void)registerNibNamed:(NSString *)nibName
  forSupplementaryClass:(Class)supplementaryClass
                forKind:(NSString *)kind
          forModelClass:(Class)modelClass;

///---------------------------------------
/// @name Search
///---------------------------------------

/**
 This method filters presented table items, using searchString as a criteria. Current storage is queried with `searchingStorageForSearchString:inSearchScope:` method. If searchString is not empty, UICollectionViewDatasource is assigned to searchingStorage and collection view is reloaded automatically.
 
 @param searchString Search string used as a criteria for filtering.
 */
-(void)filterModelsForSearchString:(NSString *)searchString;

/**
 This method filters presented table items, using searchString as a criteria. Current storage is queried with `searchingStorageForSearchString:inSearchScope:` method. If searchString or scopeNumber is not empty, UICollectionViewDatasource is assigned to searchingStorage and collection view is reloaded automatically.
 
 @param searchString Search string used as a criteria for filtering.
 
 @param scopeNumber Scope number of UISearchBar
 */
-(void)filterModelsForSearchString:(NSString *)searchString
                           inScope:(NSInteger)scopeNumber;

/**
 Returns whether search is active, based on current searchString and searchScope, retrieved from UISearchBarDelegate methods.
 */

-(BOOL)isSearching __attribute__((objc_requires_super));

@end
