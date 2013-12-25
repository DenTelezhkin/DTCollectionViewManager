//
//  MoveSections.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 17.08.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "SectionsController.h"
#import "ExampleCell.h"
#import "ExampleHeaderView.h"
#import "ExampleFooterView.h"

@interface SectionsController()
@property (strong, nonatomic) IBOutlet UINavigationItem *sectionsNavigationItem;
@property (nonatomic, assign) int sectionNumber;
@end

@implementation SectionsController

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
    
    UIBarButtonItem * moveItem = [[UIBarButtonItem alloc] initWithTitle:@"Move"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(moveSections:)];
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(addSection)];
    UIBarButtonItem * removeItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(removeSection)];
    
    [self.sectionsNavigationItem setRightBarButtonItems:@[moveItem,addItem,removeItem]
                                               animated:NO];
    
    [self addSection];
    [self addSection];
}

-(void)addSection
{
    self.sectionNumber ++;
    [self.memoryStorage setSupplementaries:@[@(self.sectionNumber)] forKind:UICollectionElementKindSectionHeader];
    [self.memoryStorage setSupplementaries:@[@(self.sectionNumber)] forKind:UICollectionElementKindSectionFooter];
    [self.memoryStorage addItems:@[@1,@2,@3] toSection:[self.memoryStorage.sections count]];
}

- (void)moveSections:(id)sender
{
    if ([self.memoryStorage.sections count])
    {
        [self moveSection:[self.memoryStorage.sections count]-1 toSection:0];
    }
}

-(void)removeSection
{
    if ([self.memoryStorage.sections count])
    {
        [self.memoryStorage deleteSections:[NSIndexSet indexSetWithIndex:[self.memoryStorage.sections count] -1]];
    }
}

@end
