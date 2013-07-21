//
//  SupplementaryView.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTCollectionViewManager.h"

@interface SupplementaryView : UICollectionReusableView <DTCollectionViewModelTransfer>

@property (nonatomic, assign) BOOL inittedWithFrame;
@property (nonatomic, assign) BOOL awakenFromNib;

@end
