//
//  DTCollectionViewStorageUpdate.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 28.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionViewStorageUpdate.h"

@implementation DTCollectionViewStorageUpdate

+(instancetype)collectionViewUpdateWithUpdate:(DTStorageUpdate *)update
{
    DTCollectionViewStorageUpdate * collectionUpdate = [self new];
    
    collectionUpdate.deletedSectionIndexes = update.deletedSectionIndexes;
    collectionUpdate.insertedSectionIndexes = update.insertedSectionIndexes;
    collectionUpdate.updatedSectionIndexes = update.updatedSectionIndexes;
    
    collectionUpdate.deletedRowIndexPaths = update.deletedRowIndexPaths;
    collectionUpdate.insertedRowIndexPaths = update.insertedRowIndexPaths;
    collectionUpdate.updatedRowIndexPaths = update.updatedRowIndexPaths;
    
    return collectionUpdate;
}

@end
