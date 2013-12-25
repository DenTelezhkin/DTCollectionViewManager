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
    
    _storage = [DTMemoryStorage storage];
    _storage.delegate = self;
}

-(DTMemoryStorage *)memoryStorage
{
    if ([self.storage isKindOfClass:[DTMemoryStorage class]])
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
    else {
        // Fallback scenario. There's no header model, where it was supposed to be.
        // Returning empty, non-initialized view is bad, but it is better than crash
        view = (id)[self.factory emptySupplementaryViewOfKind:kind
                                                 forIndexPath:indexPath];
        
        //        NSLog(@"DTCollectionViewManager: supplementary of kind %@ not found for indexPath: %@",kind,indexPath);
    }
    // Returning nil from this method will cause crash on runtime.
    return view;
}
/*
-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewFlowLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
 
//     Workaround for UICollectionView bug with insertItems.
//     OpenRadar: http://openradar.appspot.com/12954582
//     Stack0verflow solution: http://stackoverflow.com/questions/13904049/assertion-failure-in-uicollectionviewdata-indexpathforitematglobalindex

    return [self numberOfCollectionItemsInSection:section] ? collectionViewLayout.headerReferenceSize : CGSizeZero;
}
*/

-(void)moveItem:(id)item toIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)moveSection:(int)fromSection toSection:(int)toSection
{
    
}

-(void)performUpdate:(DTStorageUpdate *)update
{
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteSections:update.deletedSectionIndexes];
        [self.collectionView insertSections:update.insertedSectionIndexes];
        [self.collectionView reloadSections:update.updatedSectionIndexes];
        
        [self.collectionView deleteItemsAtIndexPaths:update.deletedRowIndexPaths];
        [self.collectionView insertItemsAtIndexPaths:update.insertedRowIndexPaths];
        [self.collectionView reloadItemsAtIndexPaths:update.updatedRowIndexPaths];
    } completion:nil];
}

@end
