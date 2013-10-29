//
//  PrototypedCollectionViewFooter.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 24.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "PrototypedCollectionViewFooter.h"

@implementation PrototypedCollectionViewFooter

-(void)updateWithModel:(id)model
{
    self.footerTitle.text = model;
}

@end
