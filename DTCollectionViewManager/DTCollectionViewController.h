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

#import "DTMemoryStorage+DTCollectionViewManagerAdditions.h"
#import <DTModelStorage/DTStorageProtocol.h>
#import "DTCollectionViewControllerEvents.h"

#pragma clang assume_nonnull begin

/**
 `DTCollectionViewController` manages all `UICollectionView` datasource methods and provides API for mapping your data models to UICollectionViewCells. It also contains storage object, that is responsible for providing data models.
 */

@interface DTCollectionViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate, UISearchBarDelegate, DTCollectionViewControllerEvents>

///---------------------------------------
/// @name Properties
///---------------------------------------

/**
 
 Collection view that will present your data models. Delegate and datasource properties are set automatically.
 */
@property (nonatomic,retain) IBOutlet UICollectionView * collectionView;

/*
 Property to store UISearchBar, attached to your UITableView. Attaching it to this property is completely optional. 
 */
@property (nonatomic, retain, nullable) IBOutlet UISearchBar * searchBar;

/**
 Storage object, used as a datasource for collection view models.
 */

@property (nonatomic, strong, null_resettable) id <DTStorageProtocol> storage;

/**
 Searching data storage object. It will be created automatically, responding to changes in UISearchBar, or after method filterTableItemsForSearchString:inScope: is called.
 */

@property (nonatomic, strong, nullable) id <DTStorageProtocol> searchingStorage;

/**
 Convenience method, that allows retrieving memory storage. If data storage class is different than DTMemoryStorage, this method will return nil.
 
 @return memory storage object
 */
-(null_unspecified DTMemoryStorage *)memoryStorage;

///---------------------------------------
/// @name Mapping
///---------------------------------------

/**
 Register mapping from model class to cell class. This will automatically check for nib with the same name as `cellClass`. If it exists - nib will be registered instead of class.
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to cellClass.
 
 @discussion This is the designated mapping method. Best place to call it - in viewDidLoad method.
 
 */
-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;

/**
 Register mapping from model class to cell class with custom nib name.
 
 @param nibName Name of the nib file with cell
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to cellClass.
 */
-(void)registerNibNamed:(NSString *)nibName forCellClass:(Class)cellClass forModelClass:(Class)modelClass;

/**
 Register `supplementaryClass` for UICollectionView supplementary `kind`. `supplementaryClass` should be a UICollectionReusableView subclass, conforming to `DTModelTransfer` protocol. xib file for supplementary class with `supplementaryClass` name is automatically detected if it exists.
 
 @param supplementaryClass UICollectionReusableView subclass to be mapped for `modelClass`.
 
 @param kind UICollectionView supplementary view kind.
 
 @param modelClass modelClass to be mapped to `supplementaryClass`
 */
- (void)registerSupplementaryClass:(Class)supplementaryClass
                          forKind:(NSString *)kind
                    forModelClass:(Class)modelClass;

/**
 Register `headerClass` for UICollectionElementKindHeader. `headerClass` should be a UICollectionReusableView subclass, conforming to `DTModelTransfer` protocol. xib file for supplementary class with `headerClass` name is automatically detected if it exists.
 
 @param headerClass UICollectionReusableView subclass to be mapped for `modelClass`.
 
 @param modelClass modelClass to be mapped to `headerClass`.
 */
- (void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass;

/**
 Register `footerClass` for UICollectionElementKindFooter. `footerClass` should be a UICollectionReusableView subclass, conforming to `DTModelTransfer` protocol. xib file for supplementary class with `footerClass` name is automatically detected if it exists.
 
 @param footerClass UICollectionReusableView subclass to be mapped for `modelClass`.
 
 @param modelClass modelClass to be mapped to `footerClass`.
 */
- (void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass;

/**
 Register `supplementaryClass` for UICollectionView supplementary `kind`. `supplementaryClass` should be a UICollectionReusableView subclass, conforming to `DTModelTransfer` protocol.
 
 @param nibName name of the nib file to be used
 
 @param supplementaryClass UICollectionReusableView subclass to be mapped for `modelClass`.
 
 @param kind UICollectionView supplementary view kind.
 
 @param modelClass modelClass to be mapped to `supplementaryClass`
 
 */
-(void)registerNibNamed:(NSString *)nibName
  forSupplementaryClass:(Class)supplementaryClass
                forKind:(NSString *)kind
          forModelClass:(Class)modelClass;

/**
 Register `headerClass` for UICollectionElementKindHeader. `headerClass` should be a UICollectionReusableView subclass, conforming to `DTModelTransfer` protocol.
 
 @param nibName name of the nib file to be used
 
 @param headerClass UICollectionReusableView subclass to be mapped for `modelClass`.
 
 @param modelClass modelClass to be mapped to `headerClass`
 */
- (void)registerNibNamed:(NSString *)nibName forHeaderClass:(Class)headerClass modelClass:(Class)modelClass;

/**
 Register `footerClass` for UICollectionElementKindFooter. `footerClass` should be a UICollectionReusableView subclass, conforming to `DTModelTransfer` protocol.
 
 @param nibName name of the nib file to be used
 
 @param footerClass UICollectionReusableView subclass to be mapped for `modelClass`.
 
 @param modelClass modelClass to be mapped to `footerClass`
 */
- (void)registerNibNamed:(NSString *)nibName forFooterClass:(Class)footerClass modelClass:(Class)modelClass;

///---------------------------------------
/// @name Search
///---------------------------------------

/**
 Filter presented table items, using searchString as a criteria. Current storage is queried with `searchingStorageForSearchString:inSearchScope:` method. If searchString is not empty, UICollectionViewDatasource is assigned to searchingStorage and collection view is reloaded automatically.
 
 @param searchString Search string used as a criteria for filtering.
 */
-(void)filterModelsForSearchString:(NSString *)searchString;

/**
 Filter presented table items, using searchString as a criteria. Current storage is queried with `searchingStorageForSearchString:inSearchScope:` method. If searchString or scopeNumber is not empty, UICollectionViewDatasource is assigned to searchingStorage and collection view is reloaded automatically.
 
 @param searchString Search string used as a criteria for filtering.
 
 @param scopeNumber Scope number of UISearchBar
 */
-(void)filterModelsForSearchString:(NSString *)searchString
                           inScope:(NSInteger)scopeNumber;

/**
 Returns whether search is active, based on current searchString and searchScope, retrieved from UISearchBarDelegate methods.
 */

-(BOOL)isSearching NS_REQUIRES_SUPER;

/**
 Perform animated update on UICollectionView. It can be used for complex animations, that should be run simultaneously. For example, `DTCollectionViewManagerAdditions` category on `DTMemoryStorage` uses it to implement moving items between indexPaths.
 
 @param animationBlock animation block to run on UICollectionView.
 */
-(void)performAnimatedUpdate:(void (^)(UICollectionView *))animationBlock;

@end

#pragma clang assume_nonnull end
