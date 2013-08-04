//
//  AddRemoveCollectionController.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 04.08.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "AddRemoveCollectionController.h"

@interface AddRemoveCollectionController ()

@end

@implementation AddRemoveCollectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                             target:self
                                                                                             action:@selector(addItem)]];
}

-(void)addItem
{
    
}

@end
