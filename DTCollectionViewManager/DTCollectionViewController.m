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
#import "DTSection.h"

@interface DTCollectionViewController ()
<DTCollectionFactoryDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) NSMutableArray *sections;
@property (nonatomic, retain) NSMutableDictionary * supplementaryModels;
@property (nonatomic, retain) DTCollectionViewFactory * factory;
@end

static BOOL isLoggingEnabled = YES;

@implementation DTCollectionViewController

-(void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

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

-(DTCollectionViewFactory *)factory
{
    if (!_factory)
    {
        _factory = [DTCollectionViewFactory new];
        _factory.delegate = self;
    }
    return _factory;
}

-(int)numberOfSections
{
    return [self.sections count];
}

- (NSArray *)itemsArrayForSection:(int)section
{
    if ([self.sections count] > section)
    {
        return self.sections[section];
    }
    else if ([self.sections count] == section)
    {
        [self.sections addObject:[NSMutableArray array]];
        return [self.sections lastObject];
    }
    else
    {
        return nil;
    }
}

-(int)numberOfCollectionItemsInSection:(int)section
{
    if (section<[self.sections count])
    {
        return [self.sections[section] count];
    }
    else {
        return 0;
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

- (NSIndexPath *)indexPathOfCollectionItem:(NSObject *)item
{
    NSIndexPath * indexPath = [self indexPathOfItem:item inArray:self.sections];
    if (!indexPath)
    {
        if ([[self class] isLoggingEnabled])
        {
            NSLog(@"DTCollectionViewManager: collection item not found, cannot return it's indexPath");
        }
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
            if ([[self class] isLoggingEnabled])
            {
                NSLog(@"DTCollectionViewManager: object %@ not found",
                      [items objectAtIndex:i]);
            }
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
    
    // iOS 6 crashes on insertion of first element in section
    // http://openradar.appspot.com/12954582
    if ([self iOS6] && modelItemPath.row == 0)
    {
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    }
    else {
        if ([self.collectionView numberOfItemsInSection:modelItemPath.section] == modelItemPath.row)
        {
            /*
             iOS 7 workaround.
             Prevent application crash from Assertion in -[UICollectionViewData indexPathForItemAtGlobalIndex:]
             Also, collection view items will display incorrectly.
             Head on to DTCollectionViewManager Readme for a workaround if you encounter this in your application.
             */
            @try {
                [self.collectionView insertItemsAtIndexPaths:@[modelItemPath]];
            }
            @catch (NSException *exception) {
                NSLog(@"DTCollectionViewManager: insert items exception: %@",exception);
            }
        }
    }
}

-(void)addCollectionItems:(NSArray *)items toSection:(int)section
{
    NSMutableArray * sectionItems = [self validCollectionSection:section];
    
    NSMutableArray * indexes = [NSMutableArray arrayWithCapacity:[items count]];
    
    int startingIndex = [sectionItems count];
    
    for (id item in items)
    {
        [indexes addObject:[NSIndexPath indexPathForItem:startingIndex
                                               inSection:section]];
        startingIndex++;
    }
    
    [sectionItems addObjectsFromArray:items];
    
    // iOS 6 crashes on insertion of first element in section
    // http://openradar.appspot.com/12954582
    NSIndexPath * firstItem = [NSIndexPath indexPathForItem:0 inSection:section];
    if ([self iOS6] && [indexes containsObject:firstItem])
    {
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    }
    else {
        /*
         iOS 7 workaround.
         Prevent application crash from Assertion in -[UICollectionViewData indexPathForItemAtGlobalIndex:]
         Also, collection view items will display incorrectly.
         Head on to DTCollectionViewManager Readme for a workaround if you encounter this in your application.
         */
        @try {
            [self.collectionView insertItemsAtIndexPaths:indexes];
        }
        @catch (NSException *exception) {
            NSLog(@"DTCollectionViewManager: insert items exception: %@",exception);
        }
    }
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
        if ([[self class] isLoggingEnabled])
        {
            NSLog(@"DTCollectionViewManager: item to delete: %@ was not found in collection view",item);
        }
        return;
    }
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

-(void)removeCollectionItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath && indexPath.section<[self numberOfSections] &&
        indexPath.item < [self.sections[indexPath.section] count])
    {
        NSMutableArray * section = (NSMutableArray *)[self itemsArrayForSection:indexPath.section];
        [section removeObjectAtIndex:indexPath.row];
    }
    else {
        if ([[self class] isLoggingEnabled])
        {
            NSLog(@"DTCollectionViewManager: indexPath to delete: %@ was not found in collection view",indexPath);
        }
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

-(void)removeCollectionItemsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray * validIndexPaths = [NSMutableArray arrayWithCapacity:[indexPaths count]];
    NSMutableSet * validSectionsToRemoveFrom = [NSMutableSet set];
    for (NSIndexPath * indexPath in indexPaths)
    {
        if (indexPath.section < [self numberOfSections] &&
            indexPath.item < [self.sections[indexPath.section] count])
        {
            [validIndexPaths addObject:indexPath];
            [validSectionsToRemoveFrom addObject:@(indexPath.section)];
        }
    }
    
    for (NSNumber * section in validSectionsToRemoveFrom)
    {
        NSMutableIndexSet * setToRemove = [NSMutableIndexSet indexSet];
        for (NSIndexPath * indexPath in validIndexPaths)
        {
            if (indexPath.section == [section intValue])
            {
                [setToRemove addIndex:indexPath.item];
            }
        }
        NSMutableArray * validSection = [self validCollectionSection:[section intValue]];
        [validSection removeObjectsAtIndexes:setToRemove];
    }
    [self.collectionView deleteItemsAtIndexPaths:validIndexPaths];
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
        if ([[self class] isLoggingEnabled])
        {
            NSLog(@"DTCollectionViewManager: failed to insert item for indexPath section: %d, row: %d, only %d items in section",
                  indexPath.section,
                  indexPath.row,
                  [array count]);
        }
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
        if ([[self class] isLoggingEnabled])
        {
            NSLog(@"DTCollectionViewManager: item %@ not found in collectionView",item);
        }
        return;
    }
    
    NSMutableArray * sourceSection = [self validCollectionSection:sourceIndexPath.section];
    NSMutableArray * destinationSection = [self validCollectionSection:indexPath.section];
    
    if ([destinationSection count] < indexPath.row)
    {
        if ([[self class] isLoggingEnabled])
        {
            NSLog(@"DTCollectionViewManager: failed moving item to indexPath: %@, only %d items in section",indexPath,[destinationSection count]);
        }
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
        if ([[self class] isLoggingEnabled])
        {
            NSLog(@"DTCollectionViewManager: failed to replace item %@ at indexPath: %@",newItem,oldIndexPath);
        }
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
    
    NSArray * supplementaryKinds = [self.supplementaryModels allKeys];
    for (NSString * kind in supplementaryKinds)
    {
        NSMutableArray * supp = [self.supplementaryModels[kind] objectAtIndex:fromSection];
        if ([self.supplementaryModels[kind] count] == [self.sections count])
        {
            [self.supplementaryModels[kind] removeObjectAtIndex:fromSection];
            [self.supplementaryModels[kind] insertObject:supp atIndex:toSection];
        }
        else {
            if ([[self class] isLoggingEnabled])
            {
                NSLog(@"DTCollectionViewManager: number of supplementary models for kind: %@ differs from section number. Moving section, leaving supplementary models untouched.",kind);
            }
        }
    }
    
    [self.sections removeObjectAtIndex:fromSection];
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
    
    NSArray * supplementaryKinds = [self.supplementaryModels allKeys];
    for (NSString * kind in supplementaryKinds)
    {
        [self.supplementaryModels[kind] removeObjectsAtIndexes:indexSet];
    }
    
    [self.collectionView deleteSections:indexSet];
}

#pragma mark - UICollectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.dataStorage)
    {
        return [[self.dataStorage sections] count];
    }
    
    return [self.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)sectionNumber
{
    if (self.dataStorage)
    {
        id <DTSection> section = [self.dataStorage sections][sectionNumber];
        return [section numberOfObjects];
    }
    
    NSArray *itemsInSection = self.sections[sectionNumber];
    
    return [itemsInSection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell <DTModelTransfer> *cell;
    id model = nil;
    
    if (self.dataStorage)
    {
        model = [self.dataStorage objectAtIndexPath:indexPath];
    }
    else {
        NSArray *itemsInSection = self.sections[indexPath.section];
        model = itemsInSection[indexPath.row];
    }    
    cell = [self.factory cellForItem:model atIndexPath:indexPath];
    [cell updateWithModel:model];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView <DTModelTransfer> *view = nil;
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

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewFlowLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    /*
     Workaround for UICollectionView bug with insertItems.
     OpenRadar: http://openradar.appspot.com/12954582
     Stack0verflow solution: http://stackoverflow.com/questions/13904049/assertion-failure-in-uicollectionviewdata-indexpathforitematglobalindex
     */
    return [self numberOfCollectionItemsInSection:section] ? collectionViewLayout.headerReferenceSize : CGSizeZero;
}

-(NSMutableArray *)validCollectionSection:(int)sectionIndex
{
    if (sectionIndex < self.sections.count)
    {
        return (NSMutableArray *)self.sections[sectionIndex];
    }
    else
    {
        NSMutableIndexSet * sectionsToInsert = [NSMutableIndexSet indexSet];
        for (int i = self.sections.count; i <= sectionIndex ; i++)
        {
            //Update datasource
            NSMutableArray *newSection = [NSMutableArray array];
            [self.sections addObject:newSection];
            
            if ([self.collectionView numberOfSections] <= i)
            {
                [sectionsToInsert addIndex:i];
            }
        }
        if ([sectionsToInsert count])
        {
            if ([self iOS6])
            {
                [self.collectionView reloadData];
            }
            else {
                [self.collectionView insertSections:sectionsToInsert];
            }
        }
        return [self.sections lastObject];
    }
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

+(void)setLoggingEnabled:(BOOL)isEnabled
{
    isLoggingEnabled = isEnabled;
}

+(BOOL)isLoggingEnabled
{
    return isLoggingEnabled;
}

-(BOOL)iOS6
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    return [version hasPrefix:@"6."];
}

@end
