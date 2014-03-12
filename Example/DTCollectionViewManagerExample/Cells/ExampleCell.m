//
//  ExampleCell.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 11.08.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "ExampleCell.h"

@implementation ExampleCell

-(void)updateWithModel:(id)model
{
    if ([model isKindOfClass:[NSString class]])
    {
        self.contentView.backgroundColor = [UIColor redColor];
    }
    if ([model isKindOfClass:[NSNumber class]])
    {
        self.contentView.backgroundColor = [UIColor greenColor];
    }
    if ([model isKindOfClass:[NSDictionary class]])
    {
        self.contentView.backgroundColor = [UIColor blueColor];
    }
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected)
    {
        self.backgroundColor = [UIColor magentaColor];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}


@end
