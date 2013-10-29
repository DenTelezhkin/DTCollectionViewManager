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

@interface ExamplesViewController()
@property (nonatomic, strong) NSMutableArray * examples;
@end

static NSString * exampleCellReuseIdentifier = @"ExampleCellReuseId";

@implementation ExamplesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.examples = [NSMutableArray array];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:exampleCellReuseIdentifier];
    
    [self.examples addObject:[ControllerModel modelWithClass:[AddRemoveCollectionController class]
                                                    andTitle:@"Add/Remove"]];
    [self.examples addObject:[ControllerModel modelWithClass:[SectionsController class]
                                                    andTitle:@"Move sections"]];
    [self.examples addObject:[ControllerModel modelWithClass:[StoryboardViewController class]
                                                    andTitle:@"Storyboard"]];
    [self.tableView reloadData];
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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
