//
//  DTCollectionViewStorageUpdating.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 28.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTStorage.h"

@protocol DTCollectionViewStorageUpdating <DTStorageUpdating>

-(void)performAnimatedUpdate:(void(^)(UICollectionView *))animationBlock;

@end
