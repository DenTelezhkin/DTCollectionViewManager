//
//  MasterViewController.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 20.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "ExamplesViewController.h"
#import "ControllerModel.h"
#import "EmptyDetailViewController.h"
#import "AddRemoveCollectionController.h"
#import "SectionsController.h"
#import "StoryboardViewController.h"
#import "SearchViewController.h"
#import "ExampleLegacy-Swift.h"

@interface ExamplesViewController()
@property (nonatomic, strong) NSMutableArray * examples;
@end

static NSString * exampleCellReuseIdentifier = @"ExampleCellReuseId";

@implementation ExamplesViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.examples = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:exampleCellReuseIdentifier];
    
    [self.examples addObject:[ControllerModel modelWithClass:[AddRemoveCollectionController class]
                                                    andTitle:@"Add/Remove"]];
    [self.examples addObject:[ControllerModel modelWithClass:[SectionsController class]
                                                    andTitle:@"Move sections"]];
    [self.examples addObject:[ControllerModel modelWithClass:[StoryboardViewController class]
                                                    andTitle:@"Storyboard"]];
    [self.examples addObject:[ControllerModel modelWithClass:[SearchViewController class]
                                                    andTitle:@"Search"]];
    [self.examples addObject:[ControllerModel modelWithClass:[SwiftViewController class]
                                                    andTitle:@"Swift"]];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.examples count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:exampleCellReuseIdentifier
                                                             forIndexPath:indexPath];
    ControllerModel * model = self.examples[indexPath.row];
    cell.textLabel.text = model.title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ControllerModel * model = self.examples[indexPath.row];
    UIViewController * controller;
    if (model.controllerClass == [StoryboardViewController class])
    {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        controller = [storyboard instantiateInitialViewController];
    }
    else {
        controller = [model.controllerClass new];
    }
    
    [self.splitViewController setViewControllers:@[self,controller]];
}

@end
