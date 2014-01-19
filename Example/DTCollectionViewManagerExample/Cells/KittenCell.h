//
//  KittenCell.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 19.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionViewCell.h"

@interface KittenCell : DTCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *kittenImage;
@property (weak, nonatomic) IBOutlet UILabel *kittenName;

@end
