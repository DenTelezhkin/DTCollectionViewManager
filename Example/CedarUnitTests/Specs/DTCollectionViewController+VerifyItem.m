//
//  DTCollectionViewController+VerifyItem.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionViewController+VerifyItem.h"

@implementation DTCollectionViewController (VerifyItem)

-(BOOL)verifyCollectionItem:(id)item atIndexPath:(NSIndexPath *)path
{
    id itemDatasource = [self collectionItemAtIndexPath:path];
    id itemCollection = [(id <DTCollectionViewModelTransfer>)[self collectionView:self.collectionView cellForItemAtIndexPath:path] model];
    
    if (![item isEqual:itemDatasource])
        return NO;
    
    if (![item isEqual:itemCollection])
        return NO;
    
    // ALL 3 are equal
    return YES;
}

-(BOOL)verifySection:(NSArray *)section withSectionNumber:(int)sectionNumber
{
    for (int itemNumber = 0; itemNumber < [section count]; itemNumber++)
    {
        if (![self verifyCollectionItem:section[itemNumber]
                            atIndexPath:[NSIndexPath indexPathForItem:itemNumber
                                                            inSection:sectionNumber]])
        {
            return NO;
        }
    }
    int itemsInSection = [self.collectionView numberOfItemsInSection:sectionNumber];
    if (itemsInSection!=[section count])
    {
        return NO;
    }
    return YES;
}

@end
