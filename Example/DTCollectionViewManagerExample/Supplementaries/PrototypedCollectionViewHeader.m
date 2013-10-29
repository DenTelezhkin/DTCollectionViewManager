//
//  PrototypedCollectionViewHeader.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "PrototypedCollectionViewHeader.h"

@implementation PrototypedCollectionViewHeader

-(void)updateWithModel:(id)model
{
    self.headerTitle.text = model;
}

@end
