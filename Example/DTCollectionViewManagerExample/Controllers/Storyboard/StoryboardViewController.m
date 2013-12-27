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

    [self.memoryStorage setSupplementaries:@[@"Section 1 header",@"Section 2 header"]
                                   forKind:UICollectionElementKindSectionHeader];
    [self.memoryStorage setSupplementaries:@[@"Section 1 footer",@"Section 2 footer"]
                                   forKind:UICollectionElementKindSectionFooter];
    [self.memoryStorage addItems:@[@"1",@"2",@"3"]];
    [self.memoryStorage addItems:@[@"1",@"2"] toSection:1];
}

@end
