//
//  DTMemoryStorage+DTCollectionViewManagerAdditions.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.08.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
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
#import "DTCollectionViewControllerEvents.h"

@interface DTMemoryStorage()

// private methods and properties on DTMemoryStorage, that we need access in this class
-(DTSectionModel *)getValidSection:(NSUInteger)sectionNumber;
@property (nonatomic, retain) DTStorageUpdate * currentUpdate;
-(void)startUpdate;
-(void)finishUpdate;
@end

@protocol DTCollectionViewStorageUpdating <DTStorageUpdating>

-(void)performAnimatedUpdate:(void(^)(UICollectionView *))animationBlock;

@end

@implementation DTMemoryStorage(DTCollectionViewManagerAdditions)

-(void)moveCollectionItemAtIndexPath:(NSIndexPath *)sourceIndexPath
                         toIndexPath:(NSIndexPath *)destinationIndexPath;
{
    [self startUpdate];
    
    id item = [self objectAtIndexPath:sourceIndexPath];
    
    if (!sourceIndexPath || !item)
    {
        if ([self loggingEnabled])
        {
            NSLog(@"DTCollectionViewManager: source indexPath should not be nil when moving collection item");
        }
        return;
    }
    DTSectionModel * sourceSection = [self getValidSection:sourceIndexPath.section];
    DTSectionModel * destinationSection = [self getValidSection:destinationIndexPath.section];
    
    if ([destinationSection.objects count] < destinationIndexPath.row)
    {
        if ([self loggingEnabled])
        {
            NSLog(@"DTCollectionViewManager: failed moving item to indexPath: %@, only %@ items in section",destinationIndexPath,@([destinationSection.objects count]));
        }
        self.currentUpdate = nil;
        return;
    }
    
    [(id<DTCollectionViewStorageUpdating>)self.delegate performAnimatedUpdate:^(UICollectionView *collectionView) {
        NSMutableIndexSet * sectionsToInsert = [NSMutableIndexSet indexSet];
        [self.currentUpdate.insertedSectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            if ([collectionView numberOfSections] <= idx)
            {
                [sectionsToInsert addIndex:idx];
            }
        }];
        [collectionView performBatchUpdates:^{
            [collectionView insertSections:sectionsToInsert];
        } completion:nil];
        
        [sourceSection.objects removeObjectAtIndex:sourceIndexPath.row];
        [destinationSection.objects insertObject:item
                                         atIndex:destinationIndexPath.row];
        
        if (sourceIndexPath.item == 0 && sourceSection.objects.count == 0)
        {
            [collectionView reloadData];
        }
        else {
            [collectionView performBatchUpdates:^{
                [collectionView moveItemAtIndexPath:sourceIndexPath
                                        toIndexPath:destinationIndexPath];
            } completion:nil];
        }
    }];
    
    self.currentUpdate = nil;
}

-(void)moveCollectionViewSection:(NSInteger)fromSection toSection:(NSInteger)toSection
{
    [self startUpdate];
    DTSectionModel * validSectionFrom = [self getValidSection:fromSection];
    [self getValidSection:toSection];
    
    [self.currentUpdate.insertedSectionIndexes removeIndex:toSection];
    
    [(id<DTCollectionViewStorageUpdating>)self.delegate performAnimatedUpdate:^(UICollectionView * collectionView) {
        if (self.sections.count > collectionView.numberOfSections)
        {
            //Section does not exist, moving section causes many sections to change, so we just reload
            [collectionView reloadData];
        }
        else {
            [collectionView performBatchUpdates:^{
                [collectionView insertSections:self.currentUpdate.insertedSectionIndexes];
                [self.sections removeObjectAtIndex:fromSection];
                [self.sections insertObject:validSectionFrom atIndex:toSection];
                [collectionView moveSection:fromSection toSection:toSection];
            } completion:nil];
        }
    }];
    self.currentUpdate = nil;
}

@end
