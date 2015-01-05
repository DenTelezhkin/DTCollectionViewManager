//
//  SwiftProvider.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 03.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "SwiftProvider.h"

@implementation SwiftProvider

-(instancetype)init
{
    if (self = [super init])
    {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"SwiftStoryboard" bundle:[NSBundle bundleForClass:[self class]]];
        self.controller = [storyboard instantiateInitialViewController];
    }
    return self;
}

@end
