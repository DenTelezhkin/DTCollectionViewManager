//
//  MasterViewController.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 20.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmptyDetailViewController.h"

@interface ExamplesViewController : UIViewController
                                    <UISplitViewControllerDelegate,
                                    UITableViewDataSource,
                                    UITableViewDelegate>

@property (nonatomic, strong) UISplitViewController * splitViewController;
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@end
