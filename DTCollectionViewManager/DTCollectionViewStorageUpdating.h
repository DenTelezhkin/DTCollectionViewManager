//
//  DTCollectionViewStorageUpdating.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 28.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTStorage.h"

/**
 This protocol is used to extend 'DTStorageUpdating' protocol, adding capability of custom animated updates on UICollectionView.
 */

@protocol DTCollectionViewStorageUpdating <DTStorageUpdating>

/**
 This method adds ability for memory storage subclass to perform animated update on UICollectionView, that presents its data.
 
 @param animationBlock animation block to run on UICollectionView.
 */

-(void)performAnimatedUpdate:(void(^)(UICollectionView *))animationBlock;

@end
