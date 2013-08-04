//
//  AppDelegate.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 20.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "AppDelegate.h"

#import "ExamplesViewController.h"

#import "EmptyDetailViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    ExamplesViewController *masterViewController = [ExamplesViewController new];
    EmptyDetailViewController *detailViewController = [EmptyDetailViewController new];

    self.splitViewController = [UISplitViewController new];
    self.splitViewController.delegate = masterViewController;
    self.splitViewController.viewControllers = @[masterViewController, detailViewController];
    self.window.rootViewController = self.splitViewController;
    masterViewController.splitViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
