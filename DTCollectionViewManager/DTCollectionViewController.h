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
 `DTCollectionViewController` manages all `UICollectionView` datasource methods and provides API for managing your data models in the table.
 
 ## Setup
 
 # General steps
 - You should have custom `UICollectionViewCell` subclasses that manage cell layout, using given data model (or `DTCollectionViewCell`, which is convenience UICollectionView subclass, that conforms to `DTCollectionViewModelTransfer` protocol)
 - Every cell class should be mapped to model class using mapping methods.
 - `UICollectionView` datasource and delegate is your `DTCollectionViewController` subclass.
 
 ## Managing collection items
 
 Every action that is done to collection items - add, delete, insert etc. is applied immediately. There's no need to manually reload data on your collection view.
 
 ## Mapping
 
 Use `registerCellClass:forModelClass` for mapping cell class to model. 'DTCollectionViewController' will automatically check, if there's a nib with the same name as cellClass. If it is - this nib is registered for modelClass. If there's no nib - cellClass will be registered for modelClass. Cells will be created using `dequeueReusableCellWithReuseIdentifier:forIndexPath:` method.
 
 For mapping supplementary views, use `registerSupplementaryClass:forKind:forModelClass:` method.
 
 Before executing mapping methods, make sure that collectionView property is set and collectionView is created. Good spot to call mapping methods is viewDidLoad method.
 
 ## Foundation class clusters mapping
 
 Most of the time you will have your own data models for cells. However, sometimes it's more convenient to use Foundation types, such as NSString, NSNumber, etc. For example, if you have supplementary view - header, that does not have any information except for it's title - you'll probably want to use NSString as its model. Mutable versions are also supported. 
 
 DTCollectionViewController supports mapping of following Foundation types:
  - NSString
  - NSNumber
  - NSDictionary
  - NSArray

 */

#import "DTCollectionViewStorage.h"

@interface DTCollectionViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,DTCollectionViewDataStorageUpdating>

///---------------------------------------
/// @name Properties
///---------------------------------------

/**
 
 Collection view that will present your data models.
 */
@property (nonatomic,retain) IBOutlet UICollectionView * collectionView;

@property (nonatomic, strong) id <DTCollectionViewStorage> dataStorage;

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
 This method registers `supplementaryClass` for UICollectionView supplementary `kind`. `supplementaryClass` should be a UICollectionReusableView subclass, conforming to `DTCollectionViewModelTransfer` protocol.
 
 @param supplementaryClass UICollectionReusableView subclass to be mapped for `modelClass`.
 
 @param kind UICollectionView supplementary view kind.
 
 @param modelClass modelClass to be mapped to `supplementaryClass`
 
 */
-(void)registerSupplementaryClass:(Class)supplementaryClass
                          forKind:(NSString *)kind
                    forModelClass:(Class)modelClass;

/**
 Use this method to get array of supplementary models of specific `kind`. Updating this array does not update UI. Returned array will never be nil.
 
 @param kind UICollectionView supplementary view kind.
 
 @return Mutable array of supplementary view models.
 
 */
-(NSMutableArray *)supplementaryModelsOfKind:(NSString *)kind;

///---------------------------------------
/// @name Add collection items
///---------------------------------------

/**
 Add collection item to section 0. 
 
 @param item Model you want to add to the collection view.
 */
-(void)addCollectionItem:(id)item;

/**
 Add array of collection items to section 0.
 
 @param items Array of items you want to add to the collection view.
 */
-(void)addCollectionItems:(NSArray *)items;

/**
 Add array of collection items to section `section`.
 
 @param item Item you want to add to the collection view.
 
 @param section Number of section, to which collection item will be added.
 */
-(void)addCollectionItem:(id)item toSection:(int)section;

/**
 Add array of collection items to section `section`.
 
 @param items Array of items you want to add to the collection view.
 
 @param section Number of section, to which collection items will be added.
 */
-(void)addCollectionItems:(NSArray *)items toSection:(int)section;

///---------------------------------------
/// @name Removing collection items
///---------------------------------------

/**
 Remove collection item. If `item` is not found, this method does nothing.
 
 @param item Model object you want to remove from collection view.
 */
-(void)removeCollectionItem:(id)item;

/**
 Remove collection item at given indexPath. If given `indexPath` does not exist in collection view, this method does nothing.
 
 @param indexPath indexPath of model object you want to remove from collection view.
 */
-(void)removeCollectionItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Remove collection items. If some item is not found, it is skipped.
 
 @param items Array of items you want to remove from collection view.
 */
-(void)removeCollectionItems:(NSArray *)items;

/**
 Remove collection items. If some item is not found at given indexPath, it is skipped.
 
 @param indexPaths Array of indexPaths, from which you want to remove collection items.
 */
-(void)removeCollectionItemsAtIndexPaths:(NSArray *)indexPaths;

/**
 Remove all collection items. After deletion UICollectionView gets reloadData message.
 */
-(void)removeAllCollectionItems;

///---------------------------------------
/// @name Insert, move, replace
///---------------------------------------

/**
 Insert collection item to indexPath `indexPath`. 
 
 @param item model to insert.
 
 @param indexPath Index, where item should be inserted.
 
 @warning Inserting item at index, that is not valid, will not throw an exception, and won't do anything, except logging into console about failure
 */
-(void)insertItem:(id)item atIndexPath:(NSIndexPath *)indexPath;

/**
 Move collection item to indexPath `indexPath`.
 
 @param item model to move.
 
 @param indexPath Index, where item should be moved.
 
 @warning Moving item at index, that is not valid, will not throw an exception, and won't do anything, except logging into console about failure
 */
-(void)moveItem:(id)item toIndexPath:(NSIndexPath *)indexPath;

/**
 Replace oldItem with newItem. If oldItem is not found, or newItem is `nil`, this method does nothing.
 
 @param oldItem Model object you want to replace.
 
 @param newItem Model object you are replacing it with.
 */
-(void)replaceItem:(id)oldItem withItem:(id)newItem;

///---------------------------------------
/// @name Managing sections
///---------------------------------------

/**
 Moves a section to a new location in the collection view. Supplementary models are moved automatically. 
 
 @param fromSection The index of the section to move.
 
 @param toSection The index in the collection view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
-(void)moveSection:(int)fromSection toSection:(int)toSection;

/**
 Deletes one or more sections in the collection view. Supplementary models for sections are deleted automatically.
 
 @param indexSet An index set that specifies the sections to delete from the collection view. 
 */
-(void)deleteSections:(NSIndexSet *)indexSet;

///---------------------------------------
/// @name Search
///---------------------------------------

/**
 Returns number of sections in collection view.
 
 @return number of sections in collection view.
 
 */
-(int)numberOfSections;

/**
 Returns array of collection view items in section. 
 
 @param section number of section.
 
 @return number of sections in collection view.
 
 */
-(NSArray *)itemsArrayForSection:(int)section;

/**
 Returns number of collection view items in section.
 
 @param section number of section.
 
 @return number of collection items in collection view section.
 
 */
-(int)numberOfCollectionItemsInSection:(int)section;

/**
 Returns collection item at indexPath.
 
 @param indexPath indexPath of the item you want to retrieve.
 
 @return collection item model at given indexPath. 
 
 */
-(id)collectionItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns copy of collection items in UICollectionView.
 
 @return NSArray of NSArrays - copy of all collection item models in DTCollectionViewController.
 */
-(NSArray *)sectionsArray;


/**
 Control over DTCollectionViewController logs.
 
 @param isEnabled passing YES enables logs, NO - disables them.
 */
+(void)setLoggingEnabled:(BOOL)isEnabled;

@end
