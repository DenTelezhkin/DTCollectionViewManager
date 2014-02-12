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
    [PlaceKit placeRandomImageWithSize:CGSizeMake(120, 120)
                              category:@"cats"
                            completion:^(UIImage *randomImage) {
                                self.kittenImage.image = randomImage;
                            }];

    self.kittenName.text = model;
}

@end
