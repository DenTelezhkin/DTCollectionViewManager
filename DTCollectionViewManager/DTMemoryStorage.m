//
//  DTCollectionViewMemoryStorage.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTMemoryStorage.h"
#import "DTSection.h"
#import "DTCollectionViewUpdate.h"
#import "DTSectionModel.h"
#import "DTCollectionViewController.h"

@interface DTMemoryStorage()
@property (nonatomic, strong) DTCollectionViewUpdate * currentUpdate;
@end

@implementation DTMemoryStorage

+(instancetype)storage
{
    DTMemoryStorage * storage = [self new];
    
    storage.sections = [NSMutableArray array];
    
    return storage;
}

-(id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    id <DTSection> sectionModel = [self sections][indexPath.section];
    return [sectionModel.objects objectAtIndex:indexPath.row];
}

#pragma mark - Updates

-(void)startUpdate
{
    self.currentUpdate = [DTCollectionViewUpdate new];
}

-(void)finishUpdate
{
    [self.delegate performUpdate:self.currentUpdate];
    self.currentUpdate = nil;
}

#pragma mark - Adding items

-(void)addItem:(NSObject *)item
{
    [self addItem:item toSection:0];
}

-(void)addItem:(NSObject *)tableItem toSection:(NSInteger)sectionNumber
{
    [self startUpdate];
    
    DTSectionModel * section = [self getValidSection:sectionNumber];
    NSUInteger numberOfItems = [section numberOfObjects];
    [section.objects addObject:tableItem];
    [self.currentUpdate.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                           inSection:sectionNumber]];
    
    [self finishUpdate];
}

-(void)addItems:(NSArray *)items
{
    [self addItems:items toSection:0];
}

-(void)addItems:(NSArray *)tableItems toSection:(NSInteger)sectionNumber
{
    [self startUpdate];
    
    DTSectionModel * section = [self getValidSection:sectionNumber];
    
    for (id tableItem in tableItems)
    {
        NSUInteger numberOfItems = [section numberOfObjects];
        [section.objects addObject:tableItem];
        [self.currentUpdate.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                               inSection:sectionNumber]];
    }
    
    [self finishUpdate];
}

-(void)insertItem:(NSObject *)item toIndexPath:(NSIndexPath *)indexPath
{
    [self startUpdate];
    // Update datasource
    DTSectionModel * section = [self getValidSection:indexPath.section];
    
    if ([section.objects count] < indexPath.row)
    {
        if ([[DTCollectionViewController class] isLoggingEnabled]) {
            NSLog(@"DTTableViewMemoryStorage: failed to insert item for indexPath section: %ld, row: %ld, only %lu items in section",
                  (long)indexPath.section,
                  (long)indexPath.row,
                  (unsigned long)[section.objects count]);
        }
        return;
    }
    [section.objects insertObject:item atIndex:indexPath.row];
    
    [self.currentUpdate.insertedRowIndexPaths addObject:indexPath];
    
    [self finishUpdate];
}

-(void)reloadItem:(NSObject *)item
{
    [self startUpdate];
    
    NSIndexPath * indexPathToReload = [self indexPathForItem:item];
    
    if (indexPathToReload)
    {
        [self.currentUpdate.updatedRowIndexPaths addObject:indexPathToReload];
    }
    
    [self finishUpdate];
}

- (void)replaceItem:(NSObject *)itemToReplace
           withItem:(NSObject *)replacingItem
{
    [self startUpdate];
    
    NSIndexPath * originalIndexPath = [self indexPathForItem:itemToReplace];
    if (originalIndexPath && replacingItem)
    {
        DTSectionModel *section = [self getValidSection:originalIndexPath.section];
        
        [section.objects replaceObjectAtIndex:originalIndexPath.row
                                   withObject:replacingItem];
    }
    else {
        if ([[DTCollectionViewController class] isLoggingEnabled]) {
            NSLog(@"DTCollectionViewMemoryStorage: failed to replace item %@ at indexPath: %@",replacingItem,originalIndexPath);
        }
        return;
    }
    
    [self.currentUpdate.updatedRowIndexPaths addObject:originalIndexPath];
    
    [self finishUpdate];
}

#pragma mark - Removing items

- (void)removeItem:(NSObject *)item
{
    [self startUpdate];
    
    NSIndexPath * indexPath = [self indexPathForItem:item];
    
    if (indexPath)
    {
        DTSectionModel * section = [self getValidSection:indexPath.section];
        [section.objects removeObjectAtIndex:indexPath.row];
    }
    else {
        if ([[DTCollectionViewController class] isLoggingEnabled]) {
            NSLog(@"DTCollectionViewMemoryStorage: item to delete: %@ was not found in table view",item);
        }
        return;
    }
    [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
    [self finishUpdate];
}

- (void)removeItems:(NSArray *)items
{
    [self startUpdate];
    
    NSArray * indexPaths = [self indexPathArrayForItems:items];
    
    for (NSObject * item in items)
    {
        NSIndexPath *indexPath = [self indexPathForItem:item];
        
        if (indexPath)
        {
            DTSectionModel * section = [self getValidSection:indexPath.section];
            [section.objects removeObjectAtIndex:indexPath.row];
        }
    }
    [self.currentUpdate.deletedRowIndexPaths addObjectsFromArray:indexPaths];
    [self finishUpdate];
}

#pragma  mark - Sections

-(void)deleteSections:(NSIndexSet *)indexSet
{
    [self startUpdate];
    // Update datasource
    [self.sections removeObjectsAtIndexes:indexSet];
    
    // Update interface
    [self.currentUpdate.deletedSectionIndexes addIndexes:indexSet];
    
    [self finishUpdate];
}

#pragma mark - Search

-(NSArray *)itemsInSection:(NSInteger)sectionNumber
{
    if ([self.sections count] > sectionNumber)
    {
        DTSectionModel * section = self.sections[sectionNumber];
        return [section objects];
    }
    else
    {
        return nil;
    }
}

-(id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * section = nil;
    if (indexPath.section < [self.sections count])
    {
        section = [self itemsInSection:indexPath.section];
    }
    else {
        if ([[DTCollectionViewController class] isLoggingEnabled])
        {
            NSLog(@"DTCollectionViewMemoryStorage: Section not found while searching for table item");
        }
        return nil;
    }
    
    if (indexPath.row < [section count])
    {
        return [section objectAtIndex:indexPath.row];
    }
    else {
        if ([[DTCollectionViewController class] isLoggingEnabled]) {
            NSLog(@"DTCollectionViewMemoryStorage: Row not found while searching for table item");
        }
        return nil;
    }
}

-(NSIndexPath *)indexPathForItem:(NSObject *)item
{
    for (NSInteger sectionNumber=0; sectionNumber<self.sections.count; sectionNumber++)
    {
        NSArray *rows = [self.sections[sectionNumber] objects];
        NSInteger index = [rows indexOfObject:item];
        
        if (index != NSNotFound)
        {
            return [NSIndexPath indexPathForRow:index inSection:sectionNumber];
        }
    }
    return nil;
}

#pragma mark - private

-(DTSectionModel *)getValidSection:(NSUInteger)sectionNumber
{
    if (sectionNumber < self.sections.count)
    {
        return self.sections[sectionNumber];
    }
    else {
        for (NSInteger i = self.sections.count; i <= sectionNumber ; i++)
        {
            DTSectionModel * section = [DTSectionModel new];
            [self.sections addObject:section];
            
            [self.currentUpdate.insertedSectionIndexes addIndex:i];
        }
        return [self.sections lastObject];
    }
}

//This implementation is not optimized, and may behave poorly over tables with lot of sections
-(NSArray *)indexPathArrayForItems:(NSArray *)items
{
    NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[items count]];
    
    for (NSInteger i=0; i<[items count]; i++)
    {
        NSIndexPath * foundIndexPath = [self indexPathForItem:[items objectAtIndex:i]];
        if (!foundIndexPath)
        {
            if ([[DTCollectionViewController class] isLoggingEnabled]) {
                NSLog(@"DTCOllectionViewMemoryStorage: object %@ not found",
                      [items objectAtIndex:i]);
            }
        }
        else {
            [indexPaths addObject:foundIndexPath];
        }
    }
    return indexPaths;
}

@end
