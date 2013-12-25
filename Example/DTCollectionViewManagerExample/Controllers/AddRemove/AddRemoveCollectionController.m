//
//  AddRemoveCollectionController.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 04.08.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "AddRemoveCollectionController.h"
#import "ExampleCell.h"
#import "DTMemoryStorage.h"

@interface AddRemoveCollectionController()
@property (strong, nonatomic) IBOutlet UINavigationItem *addRemoveNavigationItem;
@end

@implementation AddRemoveCollectionController

-(NSArray *)editBarButtonItems
{
    UIBarButtonItem * deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                   target:self
                                                                                   action:@selector(deleteSelectedItems)];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                 target:self
                                                                                 action:@selector(doneEditing)];
    return @[doneButton,deleteButton];
}

-(NSArray *)defaultBarButtonItems
{
    UIBarButtonItem * plusButton = [[UIBarButtonItem alloc] initWithTitle:@"+3"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(addItem:)];
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                 target:self
                                                                                 action:@selector(editTapped:)];
    return @[editButton,plusButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.allowsSelection = NO;
    self.collectionView.allowsMultipleSelection = YES;
    
    [self registerCellClass:[ExampleCell class] forModelClass:[NSString class]];
    [self registerCellClass:[ExampleCell class] forModelClass:[NSNumber class]];
    [self registerCellClass:[ExampleCell class] forModelClass:[NSDictionary class]];
    
    [self.addRemoveNavigationItem setRightBarButtonItems:[self defaultBarButtonItems]];
}

#pragma mark - actions

-(void)addItem:(id)sender
{
    [self.memoryStorage addItems:@[@"",@0,@{}] toSection:0];
    [self.memoryStorage addItems:@[@"",@0,@{}] toSection:1];
}

- (void)editTapped:(UIBarButtonItem *)sender
{
    [self.addRemoveNavigationItem setRightBarButtonItems:[self editBarButtonItems] animated:YES];
    self.collectionView.allowsSelection = YES;
}

-(void)deleteSelectedItems
{
    NSArray * selectedItems = [self.collectionView indexPathsForSelectedItems];
    [self.memoryStorage removeItemsAtIndexPaths:selectedItems];
}

-(void)doneEditing
{
    [self.addRemoveNavigationItem setRightBarButtonItems:[self defaultBarButtonItems] animated:YES];
    self.collectionView.allowsSelection = NO;
}


@end
