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

@property (nonatomic, retain) NSMutableDictionary *reuseIdentifiersForSupplementaryViews;
@property (nonatomic, retain) NSMutableDictionary *reuseIdentifiersForCellModels;
@property (nonatomic, retain) NSMutableDictionary * supplementaryModels;
@property (nonatomic, retain) DTCollectionFactory * factory;
@end

@implementation DTCollectionViewController

- (NSMutableDictionary *)reuseIdentifiersForSupplementaryViews
{
    if (!_reuseIdentifiersForSupplementaryViews)
    {
        _reuseIdentifiersForSupplementaryViews = [NSMutableDictionary new];
    }
    return _reuseIdentifiersForSupplementaryViews;
}

- (NSMutableDictionary *)reuseIdentifiersForCellModels
{
    if (!_reuseIdentifiersForCellModels)
    {
        _reuseIdentifiersForCellModels = [NSMutableDictionary new];
    }
    return _reuseIdentifiersForCellModels;
}

- (NSMutableArray *)sections
{
    if (!_sections)
    {
        _sections = [NSMutableArray new];
    }
    return _sections;
}

- (NSMutableArray *)headerModels
{
    if (!_headerModels)
    {
        _headerModels = [NSMutableArray new];
    }
    return _headerModels;
}

- (NSMutableArray *)footerModels
{
    if (!_footerModels)
    {
        _footerModels = [NSMutableArray new];
    }
    return _footerModels;
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

- (void)registerClass:(Class)reusableCellClass forCellReuseIdentifier:(NSString *)identifier
        forModelClass:(Class)modelClass
{
    [self.collectionView registerClass:reusableCellClass forCellWithReuseIdentifier:identifier];
    self.reuseIdentifiersForCellModels[[self reuseIdentifierForClass:modelClass]] = identifier;
}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
      forModelClass:(Class)modelClass
{
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    self.reuseIdentifiersForCellModels[[self reuseIdentifierForClass:modelClass]] = identifier;
}

- (void)registerClass:(Class)reusableViewClass forSupplementaryViewOfKind:(NSString *)kind
  withReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerClass:reusableViewClass forSupplementaryViewOfKind:kind
                   withReuseIdentifier:identifier];
    self.reuseIdentifiersForSupplementaryViews[kind] = identifier;
}

- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString *)kind
withReuseIdentifier:(NSString *)identifier
{
    [self.collectionView registerNib:nib forSupplementaryViewOfKind:kind
                 withReuseIdentifier:identifier];
    self.reuseIdentifiersForSupplementaryViews[kind] = identifier;
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
    NSString *reuseIdentifier = self.reuseIdentifiersForCellModels[[self reuseIdentifierForClass:[model class]]];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                     forIndexPath:indexPath];
    [cell updateWithModel:model];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView <DTCollectionViewModelTransfer> *view;
    view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                              withReuseIdentifier:self.reuseIdentifiersForSupplementaryViews[kind]
                                                     forIndexPath:indexPath];
    NSMutableArray * supplementaries = [self supplementaryModelsOfKind:kind];
    if ([supplementaries count]>indexPath.section)
    {
        id model = supplementaries[indexPath.section];
        [view updateWithModel:model];
    }
    
    return view;
}

- (NSString *)reuseIdentifierForClass:(Class)class
{
    NSString * classString = NSStringFromClass(class);
    
    if ([classString isEqualToString:@"__NSCFConstantString"] ||
        [classString isEqualToString:@"__NSCFString"] ||
        class == [NSMutableString class])
    {
        return @"NSString";
    }
    if ([classString isEqualToString:@"__NSCFNumber"] ||
        [classString isEqualToString:@"__NSCFBoolean"])
    {
        return @"NSNumber";
    }
    if ([classString isEqualToString:@"__NSDictionaryI"] ||
        [classString isEqualToString:@"__NSDictionaryM"] ||
        class == [NSMutableDictionary class])
    {
        return @"NSDictionary";
    }
    if ([classString isEqualToString:@"__NSArrayI"] ||
        [classString isEqualToString:@"__NSArrayM"] ||
        class == [NSMutableArray class])
    {
        return @"NSArray";
    }
    return classString;
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
