//
//  StoryboardViewController.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "StoryboardViewController.h"
#import "PrototypedCell.h"
#import "PrototypedCollectionViewFooter.h"
#import "PrototypedCollectionViewHeader.h"

@implementation StoryboardViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    [self registerCellClass:[PrototypedCell class]
              forModelClass:[NSString class]];
    [self registerSupplementaryClass:[PrototypedCollectionViewFooter class]
                             forKind:UICollectionElementKindSectionFooter
                       forModelClass:[NSString class]];
    [self registerSupplementaryClass:[PrototypedCollectionViewHeader class]
                             forKind:UICollectionElementKindSectionHeader
                       forModelClass:[NSString class]];
    
    [[self supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObjectsFromArray:@[@"Section 1 header",@"Section 2 header"]];
    [[self supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObjectsFromArray:@[@"Section 1 footer",@"Section 2 footer"]];
    
    [self addCollectionItems:@[@"1",@"2",@"3"]];
    [self addCollectionItems:@[@"1",@"2"] toSection:1];
}

@end
