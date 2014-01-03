//
//  DTCollectionViewMemoryStorage.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 28.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionViewMemoryStorage.h"

@interface DTMemoryStorage()

// private methods and properties on DTMemoryStorage, that we need access in this class
-(DTSectionModel *)getValidSection:(NSUInteger)sectionNumber;
@property (nonatomic, retain) DTStorageUpdate * currentUpdate;
-(void)startUpdate;
-(void)finishUpdate;
@end

@implementation DTCollectionViewMemoryStorage

-(void)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath
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
            NSLog(@"DTCollectionViewManager: failed moving item to indexPath: %@, only %d items in section",destinationIndexPath,[destinationSection.objects count]);
        }
        self.currentUpdate = nil;
        return;
    }
 
    [self.delegate performAnimatedUpdate:^(UICollectionView *collectionView) {
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

-(void)moveSection:(int)fromSection toSection:(int)toSection
{
    [self startUpdate];
    DTSectionModel * validSectionFrom = [self getValidSection:fromSection];
    [self getValidSection:toSection];
     
    [self.currentUpdate.insertedSectionIndexes removeIndex:toSection];
    
    [self.delegate performAnimatedUpdate:^(UICollectionView * collectionView) {
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
