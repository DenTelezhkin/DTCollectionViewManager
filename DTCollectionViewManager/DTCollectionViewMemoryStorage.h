//
//  DTCollectionViewMemoryStorage.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 28.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTMemoryStorage.h"
#import "DTCollectionViewStorageUpdating.h"

@interface DTCollectionViewMemoryStorage : DTMemoryStorage

/**
 Move collection item to `indexPath`.
 
 @param item model to move.
 
 @param indexPath Index, where item should be moved.
 
 @warning Moving item at index, that is not valid, won't do anything, except logging into console about failure
 */
-(void)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath
               toIndexPath:(NSIndexPath *)destinationIndexPath;

///---------------------------------------
/// @name Managing sections
///---------------------------------------

/**
 Moves a section to a new location in the collection view. Supplementary models are moved automatically.
 
 @param fromSection The index of the section to move.
 
 @param toSection The index in the collection view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
-(void)moveSection:(NSInteger)fromSection toSection:(NSInteger)toSection;

/**
 Delegate object, that gets notified about data storage updates. If delegate does not respond to optional `DTCollectionViewMemoryStorage` methods, it will not get called.
 */
@property (nonatomic, weak) id <DTCollectionViewStorageUpdating> delegate;


@end
