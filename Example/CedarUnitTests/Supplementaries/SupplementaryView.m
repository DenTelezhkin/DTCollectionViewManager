//
//  SupplementaryView.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "SupplementaryView.h"
@interface SupplementaryView()
@property (nonatomic, retain) id dataModel;
@end

@implementation SupplementaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.inittedWithFrame = YES;
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.awakenFromNib = YES;
}

-(void)updateWithModel:(id)model
{
    self.dataModel = model;
}

-(id)model
{
    return self.dataModel;
}

@end
