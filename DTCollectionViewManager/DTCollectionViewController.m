//
//  DTCollectionViewController.m
//  DTCollectionViewManager-iPad
//
//  Created by Denys Telezhkin on 1/23/13.
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

#import "DTCollectionViewController.h"
#import "DTModelTransfer.h"
#import "DTCollectionViewFactory.h"

@interface DTCollectionViewController ()
<DTCollectionFactoryDelegate, UICollectionViewDelegateFlowLayout, DTStorageUpdating>
@property (nonatomic, assign) NSInteger currentSearchScope;
@property (nonatomic, copy) NSString * currentSearchString;
@property (nonatomic, retain) DTCollectionViewFactory * factory;


@end

@implementation DTCollectionViewController

@synthesize storage = _storage;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self setupCollectionViewDefaults];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setupCollectionViewDefaults];
    }
    return self;
}

-(void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

-(void)setupCollectionViewDefaults
{
    _currentSearchScope = -1;
    _factory = [DTCollectionViewFactory new];
    _factory.delegate = self;
}

-(DTMemoryStorage *)memoryStorage
{
    if ([self.storage isKindOfClass:[DTMemoryStorage class]])
    {
        return self.storage;
    }
    return nil;
}

-(id<DTStorageProtocol>)storage
{
    if (!_storage)
    {
        DTMemoryStorage * storage = [DTMemoryStorage storage];
        storage.supplementaryHeaderKind = UICollectionElementKindSectionHeader;
        storage.supplementaryFooterKind = UICollectionElementKindSectionFooter;
        _storage = storage;
        _storage.delegate = self;
    }
    return _storage;
}

-(void)setStorage:(id<DTStorageProtocol>)dataStorage
{
    _storage = dataStorage;
    [_storage setSupplementaryHeaderKind:UICollectionElementKindSectionHeader];
    [_storage setSupplementaryFooterKind:UICollectionElementKindSectionFooter];
    _storage.delegate = self;
}

-(void)setSearchingStorage:(id<DTStorageProtocol>)searchingStorage
{
    _searchingStorage = searchingStorage;
    [_searchingStorage setSupplementaryHeaderKind:UICollectionElementKindSectionHeader];
    [_searchingStorage setSupplementaryFooterKind:UICollectionElementKindSectionFooter];
    _searchingStorage.delegate = self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.searchBar.delegate = self;
}

#pragma mark - mapping

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    NSParameterAssert([cellClass isSubclassOfClass:[UICollectionViewCell class]]);
    NSParameterAssert([cellClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(modelClass);
    
    [self.factory registerCellClass:cellClass forModelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    NSParameterAssert(nibName.length > 0);
    NSParameterAssert([cellClass isSubclassOfClass:[UICollectionViewCell class]]);
    NSParameterAssert([cellClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(modelClass);

    [self.factory registerNibNamed:nibName forCellClass:cellClass forModelClass:modelClass];
}

-(void)registerSupplementaryClass:(Class)supplementaryClass forKind:(NSString *)kind forModelClass:(Class)modelClass
{
    NSParameterAssert([supplementaryClass isSubclassOfClass:[UICollectionReusableView class]]);
    NSParameterAssert([supplementaryClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(kind);
    NSParameterAssert(modelClass);
    
    [self.factory registerSupplementaryClass:supplementaryClass
                                     forKind:kind
                               forModelClass:modelClass];
}

- (void)registerHeaderClass:(Class)supplementaryClass forModelClass:(Class)modelClass
{
    [self registerSupplementaryClass:supplementaryClass
                             forKind:UICollectionElementKindSectionHeader
                       forModelClass:modelClass];
}

- (void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass
{
    [self registerSupplementaryClass:footerClass
                             forKind:UICollectionElementKindSectionFooter
                       forModelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forSupplementaryClass:(Class)supplementaryClass
                forKind:(NSString *)kind
          forModelClass:(Class)modelClass
{
    NSParameterAssert(nibName.length > 0);
    NSParameterAssert([supplementaryClass isSubclassOfClass:[UICollectionReusableView class]]);
    NSParameterAssert([supplementaryClass conformsToProtocol:@protocol(DTModelTransfer)]);
    NSParameterAssert(kind);
    NSParameterAssert(modelClass);
    
    [self.factory registerNibNamed:nibName
             forSupplementaryClass:supplementaryClass
                           forKind:kind
                     forModelClass:modelClass];
}

- (void)registerNibNamed:(NSString *)nibName forHeaderClass:(Class)headerClass modelClass:(Class)modelClass
{
    [self registerNibNamed:nibName
     forSupplementaryClass:headerClass
                   forKind:UICollectionElementKindSectionHeader
             forModelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forFooterClass:(Class)footerClass modelClass:(Class)modelClass
{
    [self registerNibNamed:nibName
     forSupplementaryClass:footerClass
                   forKind:UICollectionElementKindSectionFooter
             forModelClass:modelClass];
}

#pragma mark - search

-(BOOL)isSearching
{
    // If search scope is selected, we are already searching, even if dataset is all items
    if (((self.currentSearchString) && (![self.currentSearchString isEqualToString:@""]))
        ||
        self.currentSearchScope>-1)
    {
        return YES;
    }
    return NO;
}

-(void)filterModelsForSearchString:(NSString *)searchString
{
    [self filterModelsForSearchString:searchString inScope:-1];
}

-(void)filterModelsForSearchString:(NSString *)searchString
                               inScope:(NSInteger)scopeNumber
{
    BOOL wereSearching = [self isSearching];
    
    if (![searchString isEqualToString:self.currentSearchString] ||
        scopeNumber!=self.currentSearchScope)
    {
        self.currentSearchScope = scopeNumber;
        self.currentSearchString = searchString;
    }
    else {
        return;
    }
    
    if (wereSearching && ![self isSearching])
    {
        [self.collectionView reloadData];
        [self collectionControllerDidCancelSearch];
        return;
    }
    if ([self.storage respondsToSelector:@selector(searchingStorageForSearchString:inSearchScope:)])
    {
        [self collectionControllerWillBeginSearch];
        self.searchingStorage = [self.storage searchingStorageForSearchString:searchString
                                                                                                     inSearchScope:scopeNumber];
        [self.collectionView reloadData];
        [self collectionControllerDidEndSearch];
    }
}

-(id)supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSInteger)sectionNumber
{
    id <DTStorageProtocol> storage = nil;
    if ([self isSearching])
    {
        storage = self.searchingStorage;
    }
    else {
        storage = self.storage;
    }
    
    if ([storage respondsToSelector:@selector(supplementaryModelOfKind:forSectionIndex:)])
    {
        return [storage supplementaryModelOfKind:kind
                                 forSectionIndex:sectionNumber];
    }
    return nil;
}

#pragma  mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterModelsForSearchString:searchText];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self filterModelsForSearchString:searchBar.text inScope:selectedScope];
}

#pragma mark - UICollectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([self isSearching])
    {
        return [[self.searchingStorage sections] count];
    }
    else {
        return [[self.storage sections] count];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)sectionNumber
{
    if ([self isSearching])
    {
        id <DTSection> sectionModel = [self.searchingStorage sections][sectionNumber];
        return [sectionModel numberOfObjects];
    }
    else {
        id <DTSection> sectionModel = [self.storage sections][sectionNumber];
        return [sectionModel numberOfObjects];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id model = nil;
    if ([self isSearching])
    {
        model = [self.searchingStorage objectAtIndexPath:indexPath];
    }
    else {
        model = [self.storage objectAtIndexPath:indexPath];
    }
    
    UICollectionViewCell <DTModelTransfer> *cell;
    
    cell = [self.factory cellForItem:model atIndexPath:indexPath];
    [cell updateWithModel:model];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView <DTModelTransfer> *view = nil;
    id supplementary = nil;
    if ([self.storage respondsToSelector:@selector(supplementaryModelOfKind:forSectionIndex:)])
    {
        supplementary = [self.storage supplementaryModelOfKind:kind forSectionIndex:indexPath.section];
    }
    
    if (supplementary)
    {
        view = [self.factory supplementaryViewOfKind:kind
                                             forItem:supplementary
                                         atIndexPath:indexPath];
        [view updateWithModel:supplementary];
    }
    
    return view;
}

// UICollectionViewFlowLayout headers and footer size delegate methods
// They are needed, because if there are no header model, it's better to return CGSizeZero for a size of supplementary view.
// This way viewForSupplementaryElementOfKind: method will not get called
-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewFlowLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)sectionNumber
{
    BOOL supplementaryModelNotNil = NO;
    if ([self.storage respondsToSelector:@selector(supplementaryModelOfKind:forSectionIndex:)])
    {
        supplementaryModelNotNil = ([self.storage supplementaryModelOfKind:UICollectionElementKindSectionHeader
                                                           forSectionIndex:sectionNumber]!=nil);
    }
    return supplementaryModelNotNil ? collectionViewLayout.headerReferenceSize : CGSizeZero;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewFlowLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)sectionNumber
{
    BOOL supplementaryModelNotNil = NO;
    if ([self.storage respondsToSelector:@selector(supplementaryModelOfKind:forSectionIndex:)])
    {
        supplementaryModelNotNil = ([self.storage supplementaryModelOfKind:UICollectionElementKindSectionFooter
                                                           forSectionIndex:sectionNumber]!=nil);
    }
    return supplementaryModelNotNil ? collectionViewLayout.footerReferenceSize : CGSizeZero;
}

-(void)performAnimatedUpdate:(void (^)(UICollectionView *))animationBlock
{
    animationBlock(self.collectionView);
}

-(void)storageDidPerformUpdate:(DTStorageUpdate *)update
{
    [self collectionControllerWillUpdateContent];
    
    NSMutableIndexSet * sectionsToInsert = [NSMutableIndexSet indexSet];
    [update.insertedSectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if ([self.collectionView numberOfSections] <= idx)
        {
            [sectionsToInsert addIndex:idx];
        }
    }];
    
    NSInteger sectionChanges = [update.deletedSectionIndexes count] + [update.insertedSectionIndexes count] + [update.updatedSectionIndexes count];
    NSInteger itemChanges = [update.deletedRowIndexPaths count] + [update.insertedRowIndexPaths count] + [update.updatedRowIndexPaths count];
    
    if (sectionChanges)
    {
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteSections:update.deletedSectionIndexes];
            [self.collectionView insertSections:sectionsToInsert];
            [self.collectionView reloadSections:update.updatedSectionIndexes];
        } completion:nil];
    }
    
    if ([self shouldReloadCollectionViewToPreventInsertFirstItemIssueForUpdate:update])
    {
        [self.collectionView reloadData];
        return;
    }
    
    if ((itemChanges && (sectionChanges == 0)))
    {
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:update.deletedRowIndexPaths];
            [self.collectionView insertItemsAtIndexPaths:update.insertedRowIndexPaths];
            [self.collectionView reloadItemsAtIndexPaths:update.updatedRowIndexPaths];
        } completion:nil];
    }
    
    [self collectionControllerDidUpdateContent];
}

-(void)storageNeedsReload
{
    [self collectionControllerWillUpdateContent];
    
    [self.collectionView reloadData];
    
    [self collectionControllerDidUpdateContent];
}

#pragma mark - workarounds

// This is to prevent a bug in UICollectionView from occurring.
// The bug presents itself when inserting the first object or deleting the last object in a collection view.
// http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
// http://stackoverflow.com/questions/13904049/assertion-failure-in-uicollectionviewdata-indexpathforitematglobalindex
// This code should be removed once the bug has been fixed, it is tracked in OpenRadar
// http://openradar.appspot.com/12954582
-(BOOL)shouldReloadCollectionViewToPreventInsertFirstItemIssueForUpdate:(DTStorageUpdate *)update
{
    BOOL shouldReload = NO;
    
    for (NSIndexPath * indexPath in update.insertedRowIndexPaths)
    {
        if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0)
        {
            shouldReload = YES;
        }
    }
    
    for (NSIndexPath * indexPath in update.deletedRowIndexPaths)
    {
        if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1)
        {
            shouldReload = YES;
        }
    }
    
    if (self.collectionView.window == nil)
    {
        shouldReload = YES;
    }
    return shouldReload;
}

#pragma mark - DTCollectionViewControllerEvents

- (void)collectionControllerWillUpdateContent
{
    
}

- (void)collectionControllerDidUpdateContent
{
    
}

- (void)collectionControllerWillBeginSearch
{
    
}

- (void)collectionControllerDidEndSearch
{
    
}

- (void)collectionControllerDidCancelSearch
{
    
}

@end
