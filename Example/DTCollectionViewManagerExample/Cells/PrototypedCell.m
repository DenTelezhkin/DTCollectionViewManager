//
//  PrototypedCell.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "PrototypedCell.h"

@implementation PrototypedCell

-(void)updateWithModel:(id)model
{
    self.cellLabel.text = model;
}

@end
