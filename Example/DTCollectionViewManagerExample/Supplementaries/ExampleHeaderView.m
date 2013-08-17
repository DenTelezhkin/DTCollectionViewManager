//
//  ExampleHeaderView.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 17.08.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "ExampleHeaderView.h"

@interface ExampleHeaderView()
@property (strong, nonatomic) IBOutlet UILabel *sectionTitle;
@end

@implementation ExampleHeaderView

-(void)updateWithModel:(NSNumber *)model
{
    self.sectionTitle.text = [NSString stringWithFormat:@"Section header %d",[model intValue]];
}

@end
