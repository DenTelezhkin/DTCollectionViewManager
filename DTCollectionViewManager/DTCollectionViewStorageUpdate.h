//
//  DTCollectionViewStorageUpdate.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 28.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTStorageUpdate.h"

@interface DTCollectionViewStorageUpdate : DTStorageUpdate

@property (nonatomic, copy) void (^sectionAnimationBlock)(UICollectionView * collectionView);
@property (nonatomic, copy) void (^itemAnimationBlock)(UICollectionView * collectionView);

+(instancetype)collectionViewUpdateWithUpdate:(DTStorageUpdate *)update;

@end
