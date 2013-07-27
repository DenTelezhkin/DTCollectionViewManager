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

- (NSMutableArray *)itemsArrayForSection:(int)index
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

-(NSMutableArray *)supplementaryModelsOfKind:(NSString *)kind
{
    if (!self.supplementaryModels[kind])
    {
        [self.supplementaryModels setObject:[NSMutableArray array]
                                     forKey:kind];
    }
    return [self.supplementaryModels objectForKey:kind];
}

- (NSMutableArray *)sectionsArray
{
    return self.sections;
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
        view = (UICollectionReusableView <DTCollectionViewModelTransfer> *)[UICollectionReusableView new];
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
