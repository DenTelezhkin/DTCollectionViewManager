//
//  DTCollectionViewController+VerifyItem.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionViewController.h"

@interface DTCollectionViewController (VerifyItem)

-(BOOL)verifyCollectionItem:(id)item atIndexPath:(NSIndexPath *)path;

-(BOOL)verifySection:(NSArray *)section withSectionNumber:(int)sectionNumber;
@end
