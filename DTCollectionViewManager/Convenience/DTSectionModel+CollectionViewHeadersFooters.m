//
//  DTSectionModel+CollectionViewHeadersFooters.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTSectionModel+CollectionViewHeadersFooters.h"

@implementation DTSectionModel (CollectionViewHeadersFooters)

-(id)collectionHeaderModel
{
    return [self supplementaryModelOfKind:UICollectionElementKindSectionHeader];
}

-(id)collectionFooterModel
{
    return [self supplementaryModelOfKind:UICollectionElementKindSectionFooter];
}

-(void)setCollectionSectionHeader:(id)model
{
    [self setSupplementaryModel:model forKind:UICollectionElementKindSectionHeader];
}

-(void)setCollectionSectionFooter:(id)model
{
    [self setSupplementaryModel:model forKind:UICollectionElementKindSectionFooter];
}

@end
