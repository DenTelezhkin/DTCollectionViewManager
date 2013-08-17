//
//  MoveSections.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 17.08.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "MoveSectionsController.h"
#import "ExampleCell.h"
#import "ExampleHeaderView.h"
#import "ExampleFooterView.h"

@implementation MoveSectionsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCellClass:[ExampleCell class] forModelClass:[NSNumber class]];
    [self registerSupplementaryClass:[ExampleHeaderView class]
                             forKind:UICollectionElementKindSectionHeader
                       forModelClass:[NSNumber class]];
    [self registerSupplementaryClass:[ExampleFooterView class]
                             forKind:UICollectionElementKindSectionFooter
                       forModelClass:[NSNumber class]];
    
    [[self supplementaryModelsOfKind:UICollectionElementKindSectionHeader] addObjectsFromArray:@[@1,@2,@3]];
    [[self supplementaryModelsOfKind:UICollectionElementKindSectionFooter] addObjectsFromArray:@[@1,@2,@3]];
    
    [self addCollectionItems:@[@1,@2,@3] toSection:0];
    [self addCollectionItems:@[@1,@2,@3] toSection:1];
    [self addCollectionItems:@[@1,@2,@3] toSection:2];
}

- (IBAction)moveSections:(id)sender
{
    [self moveSection:2 toSection:0];
    [self.collectionView reloadData];
}
@end
