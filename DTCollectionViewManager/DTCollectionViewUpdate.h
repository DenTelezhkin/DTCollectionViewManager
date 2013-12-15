//
//  DTCollectionViewUpdate.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTCollectionViewUpdate : NSObject

/**
 Indexes of deleted sections for current update.
 */
@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;

/**
 Indexes of inserted sections for current update.
 */
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;

/**
 Indexes of updated sections for current update.
 */
@property (nonatomic, strong) NSMutableIndexSet *updatedSectionIndexes;

/**
 Index paths of deleted rows for current update.
 */
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;

/**
 Index paths of inserted rows for current update.
 */
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;

/**
 Index paths of updated rows for current update.
 */
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;

@end
