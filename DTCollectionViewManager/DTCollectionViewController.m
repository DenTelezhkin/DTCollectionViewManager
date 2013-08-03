//
//  DTCollectionViewController.m
//  DTCollectionViewManager-iPad
//
//  Created by Denys Telezhkin on 1/23/13.
//  Copyright (c) 2013 MLSDev. All rights reserved.
//

#import "DTCollectionViewController.h"
#import "DTCollectionViewModelTransfer.h"
#import "DTCollectionFactory.h"

@interface DTCollectionViewController ()
                <DTCollectionFactoryDelegate>

@property (nonatomic, retain) NSMutableArray *sections;
@property (nonatomic, retain) NSMutableDictionary * supplementaryModels;
@property (nonatomic, retain) DTCollectionFactory * factory;
@end

@implementation DTCollectionViewController

- (NSMutableArray *)sections
{
    if (!_sections)
    {
        _sections = [NSMutableArray new];
    }
    return _sections;
}

-(NSMutableDictionary *)supplementaryModels
{
    if (!_supplementaryModels)
    {
        _supplementaryModels = [NSMutableDictionary new];
    }
    return _supplementaryModels;
}

-(DTCollectionFactory *)factory
{
    if (!_factory)
    {
        _factory = [DTCollectionFactory new];
        _factory.delegate = self;
    }
    return _factory;
}

-(int)numberOfSections
{
    return [self.sections count];
}

- (NSArray *)itemsArrayForSection:(int)index
{
    if ([self.sections count] > index)
    {
        return self.sections[index];
    }
    else if ([self.sections count] == index)
    {
        [self.sections addObject:[NSMutableArray array]];
        return [self.sections lastObject];
    }
    else
    {
        return nil;
    }
}

-(id)collectionItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * itemsInSection = [self itemsArrayForSection:indexPath.section];
    
    if ([itemsInSection count]>indexPath.row)
    {
        return itemsInSection[indexPath.row];
    }
    return nil;
}

-(NSIndexPath *)indexPathOfItem:(NSObject *)item inArray:(NSArray *)array
{
    for (NSInteger section=0; section<array.count; section++)
    {
        NSArray *rows = array[section];
        NSInteger index = [rows indexOfObject:item];
        
        if (index != NSNotFound)
        {
            return [NSIndexPath indexPathForRow:index inSection:section];
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathOfCollectionItem:(NSObject *)tableItem
{
    NSIndexPath * indexPath = [self indexPathOfItem:tableItem inArray:self.sections];
    if (!indexPath)
    {
        NSLog(@"DTCollectionViewManager: collection item not found, cannot return it's indexPath");
        return nil;
    }
    else {
        return indexPath;
    }
}

//This implementation is not optimized, and may behave poorly over tables with lot of sections
-(NSArray *)indexPathArrayForCollectionItems:(NSArray *)items
{
    NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[items count]];
    
    for (NSInteger i=0; i<[items count]; i++)
    {
        NSIndexPath * foundIndexPath = [self indexPathOfCollectionItem:[items objectAtIndex:i]];
        if (!foundIndexPath)
        {
            NSLog(@"DTCollectionViewManager: object %@ not found",
                  [items objectAtIndex:i]);
        }
        else {
            [indexPaths addObject:foundIndexPath];
        }
    }
    return indexPaths;
}

-(NSMutableArray *)supplementaryModelsOfKind:(NSString *)kind
{
    if (!self.supplementaryModels[kind])
    {
        [self.supplementaryModels setObject:[NSMutableArray array]
                                     forKey:kind];
    }
    return [self.supplementaryModels objectForKey:kind];
}

- (NSArray *)sectionsArray
{
    return [self.sections copy];
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

#pragma mark - models manipulation

-(void)addCollectionItem:(id)item
{
    [self addCollectionItem:item toSection:0];
}

-(void)addCollectionItems:(NSArray *)items
{
    [self addCollectionItems:items toSection:0];
}

-(void)addCollectionItem:(id)item toSection:(int)section
{
    NSMutableArray *array = [self validCollectionSection:section];
    
    int itemsCountInSection = [array count];
    [array addObject:item];

    NSIndexPath * modelItemPath = [NSIndexPath indexPathForItem:itemsCountInSection
                                                      inSection:section];
    [self.collectionView insertItemsAtIndexPaths:@[modelItemPath]];
}

-(void)addCollectionItems:(NSArray *)items toSection:(int)section
{
    [self.collectionView performBatchUpdates:^{
        for (id item in items)
        {
            [self addCollectionItem:item toSection:section];
        }
    } completion:nil];
}

-(void)removeCollectionItem:(id)item
{
    NSIndexPath * indexPath = [self indexPathOfCollectionItem:item];

    if (indexPath)
    {
        NSMutableArray * section = (NSMutableArray *)[self itemsArrayForSection:indexPath.section];
        [section removeObjectAtIndex:indexPath.row];
    }
    else {
        NSLog(@"DTCollectionViewManager: item to delete: %@ was not found in collection view",item);
        return;
    }
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

-(void)removeCollectionItems:(NSArray *)items
{
    NSArray * indexPaths = [self indexPathArrayForCollectionItems:items];
    
    for (NSObject * item in items)
    {
        NSIndexPath *indexPath = [self indexPathOfCollectionItem:item];
        
        if (indexPath)
        {
            //update datasource
            NSArray *section = [self itemsArrayForSection:indexPath.section];
            NSMutableArray *castedSection = (NSMutableArray *)section;
            [castedSection removeObjectAtIndex:indexPath.row];
        }
    }
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
}

-(void)removeAllCollectionItems
{
    [self.sections removeAllObjects];
    
    [self.collectionView reloadData];
}

-(void)insertItem:(id)item atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * array = [self validCollectionSection:indexPath.section];
    
    if ([array count] < indexPath.row)
    {
        NSLog(@"DTCollectionViewManager: failed to insert item for indexPath section: %d, row: %d, only %d items in section",
              indexPath.section,
              indexPath.row,
              [array count]);
        return;
    }
    [array insertObject:item atIndex:indexPath.row];
    
    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
}

-(void)moveItem:(id)item toIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * sourceIndexPath = [self indexPathOfCollectionItem:item];
    
    if (!sourceIndexPath)
    {
        NSLog(@"DTCollectionViewManager: item %@ not found in collectionView",item);
        return;
    }
    
    NSMutableArray * sourceSection = [self validCollectionSection:sourceIndexPath.section];
    NSMutableArray * destinationSection = [self validCollectionSection:indexPath.section];

    if ([destinationSection count] < indexPath.row)
    {
         NSLog(@"DTCollectionViewManager: failed moving item to indexPath: %@, only %d items in section",indexPath,[destinationSection count]);
        return;
    }
    
    [sourceSection removeObjectAtIndex:sourceIndexPath.row];
    [destinationSection insertObject:item atIndex:indexPath.row];
    
    [self.collectionView moveItemAtIndexPath:sourceIndexPath
                                 toIndexPath:indexPath];
}

-(void)replaceItem:(id)oldItem withItem:(id)newItem
{
    NSIndexPath * oldIndexPath = [self indexPathOfCollectionItem:oldItem];
    
    if (!oldIndexPath || !newItem)
    {
        NSLog(@"DTCollectionViewManager: failed to replace item %@ at indexPath: %@",newItem,oldIndexPath);
        return;
    }
    NSMutableArray * section = [self validCollectionSection:oldIndexPath.section];
    
    [section replaceObjectAtIndex:oldIndexPath.row withObject:newItem];
    
    [self.collectionView reloadItemsAtIndexPaths:@[oldIndexPath]];
}

-(void)moveSection:(int)fromSection toSection:(int)toSection
{
    NSMutableArray * validSectionFrom = [self validCollectionSection:fromSection];
    [self validCollectionSection:toSection];
    
    [self.sections removeObject:validSectionFrom];
    [self.sections insertObject:validSectionFrom atIndex:toSection];
    
    if (self.sections.count > self.collectionView.numberOfSections)
    {
        //Row does not exist, moving section causes many sections to change, so we just reload
        [self.collectionView reloadData];
    }
    else {
        [self.collectionView moveSection:fromSection toSection:toSection];
    }
}

-(void)deleteSections:(NSIndexSet *)indexSet
{
    [self.sections removeObjectsAtIndexes:indexSet];
    
    [self.collectionView deleteSections:indexSet];
}

#pragma mark - UICollectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSArray *itemsInSection = self.sections[section];

    return [itemsInSection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell <DTCollectionViewModelTransfer> *cell;

    NSArray *itemsInSection = self.sections[indexPath.section];
    id model = itemsInSection[indexPath.row];
    
    cell = [self.factory cellForItem:model atIndexPath:indexPath];
    [cell updateWithModel:model];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView <DTCollectionViewModelTransfer> *view = nil;
    NSMutableArray * supplementaries = [self supplementaryModelsOfKind:kind];
    
    if ([supplementaries count]>indexPath.section)
    {
        id model = supplementaries[indexPath.section];
        
        view = [self.factory supplementaryViewOfKind:kind
                                             forItem:model
                                         atIndexPath:indexPath];
        [view updateWithModel:model];
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

-(NSMutableArray *)validCollectionSection:(int)sectionIndex
{
    if (sectionIndex < self.sections.count)
    {
        return (NSMutableArray *)self.sections[sectionIndex];
    }
    else
    {
        for (int i = self.sections.count; i <= sectionIndex ; i++)
        {
            //Update datasource
            NSMutableArray *newSection = [NSMutableArray array];
            [self.sections addObject:newSection];
            
            if ([self.collectionView numberOfSections] <= i)
            {
                //Update UI
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:i]];
            }
        }
        return [self.sections lastObject];
    }
}

@end
