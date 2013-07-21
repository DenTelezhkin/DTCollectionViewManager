//
//  DTCollectionFactory.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionFactory.h"

@implementation DTCollectionFactory

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    
}

-(void)registerSupplementaryClass:(Class)supplementaryClass
                          forKind:(NSString *)kind
                    forModelClass:(Class)modelClass
{
    
}

-(UICollectionViewCell *)cellForItem:(id)modelItem
{
    return nil;
}

-(UICollectionReusableView *)supplementaryViewForItem:(id)modelItem
{
    return nil;
}

@end
