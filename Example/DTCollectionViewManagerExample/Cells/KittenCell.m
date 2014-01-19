//
//  KittenCell.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 19.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "KittenCell.h"
#import "PlaceKit.h"

@implementation KittenCell

-(void)updateWithModel:(id)model
{
    [PlaceKit placeKittenImageWithSize:CGSizeMake(120, 120)
                            completion:^(UIImage *kittenImage) {
                                self.kittenImage.image = kittenImage;
                            }];
    self.kittenName.text = model;
}


@end
