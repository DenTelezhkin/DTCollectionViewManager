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
<DTCollectionFactoryDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) DTCollectionViewFactory * factory;
@end

@implementation DTCollectionViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}

-(void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

-(void)setup
{
    _factory = [DTCollectionViewFactory new];
    _factory.delegate = self;
    
    _storage = [DTCollectionViewMemoryStorage storage];
    _storage.delegate = self;
}

-(DTCollectionViewMemoryStorage *)memoryStorage
{
    if ([self.storage isKindOfClass:[DTCollectionViewMemoryStorage class]])
    {
        return self.storage;
    }
    return nil;
}

#pragma mark - mapping

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    [self.factory registerCellClass:cellClass forModelClass:modelClass];
}

-(void)registerSupplementaryClass:(Class)supplementaryClass forKind:(NSString *)kind forModelClass:(Class)modelClass
{
    [self.factory registerSupplementaryClass:supplementaryClass
                                     forKind:kind
                               forModelClass:modelClass];
}

#pragma mark - UICollectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.storage sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)sectionNumber
{
    id <DTSection> section = [self.storage sections][sectionNumber];
    return [section numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell <DTModelTransfer> *cell;
    id model = [self.storage objectAtIndexPath:indexPath];
       
    cell = [self.factory cellForItem:model atIndexPath:indexPath];
    [cell updateWithModel:model];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView <DTModelTransfer> *view = nil;
    id supplementary = [self.storage supplementaryModelOfKind:kind forSectionIndex:indexPath.section];

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
    id <DTSection> section = [self.storage sections][sectionNumber];
    BOOL supplementaryModelNotNil = ([self.storage supplementaryModelOfKind:UICollectionElementKindSectionHeader
                                                            forSectionIndex:sectionNumber]!=nil);
    if ([self iOS6] && ![section numberOfObjects])
    {
        supplementaryModelNotNil = NO;
    }
    return supplementaryModelNotNil ? collectionViewLayout.headerReferenceSize : CGSizeZero;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewFlowLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)sectionNumber
{
    id <DTSection> section = [self.storage sections][sectionNumber];
    BOOL supplementaryModelNotNil = ([self.storage supplementaryModelOfKind:UICollectionElementKindSectionFooter
                                                            forSectionIndex:sectionNumber]!=nil);
    if ([self iOS6] && ![section numberOfObjects])
    {
        supplementaryModelNotNil = NO;
    }
    return supplementaryModelNotNil ? collectionViewLayout.footerReferenceSize : CGSizeZero;
}

-(void)performAnimatedUpdate:(void (^)(UICollectionView *))animationBlock
{
    animationBlock(self.collectionView);
}

-(void)storageDidPerformUpdate:(DTStorageUpdate *)update
{
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
}

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

-(BOOL)iOS6
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    return [version hasPrefix:@"6."];
}

@end
