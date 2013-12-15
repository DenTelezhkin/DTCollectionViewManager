//
//  DTCOllectionViewSectionModel.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTSectionModel.h"

@implementation DTSectionModel

-(NSMutableArray *)objects
{
    if (!_objects)
    {
        _objects = [NSMutableArray array];
    }
    return _objects;
}

-(NSUInteger)numberOfObjects
{
    return [self.objects count];
}

@end
