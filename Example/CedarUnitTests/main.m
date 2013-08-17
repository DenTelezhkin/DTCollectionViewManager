//
//  main.m
//  CedarUnitTests
//
//  Created by Denys Telezhkin on 20.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [DTCollectionViewController setLoggingEnabled:NO];
        return UIApplicationMain(argc, argv, nil, @"CedarApplicationDelegate");
    }
}
