//
//  SearchCollectionViewController.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 19.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "SearchViewController.h"
#import "KittenCell.h"
#import "PlaceKit.h"
@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerCellClass:[KittenCell class]
              forModelClass:[NSString class]];
    
    [[self memoryStorage] addItems:[self kittensArrayOfSize:50]];
}

-(NSArray *)kittensArrayOfSize:(NSInteger)size
{
    NSMutableArray * kittensArray = [NSMutableArray arrayWithCapacity:size];
    for (int i=0;i<size;i++)
    {
        [kittensArray addObject:[PlaceKit placeRandomFirstName]];
    }
    return kittensArray;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}
@end
