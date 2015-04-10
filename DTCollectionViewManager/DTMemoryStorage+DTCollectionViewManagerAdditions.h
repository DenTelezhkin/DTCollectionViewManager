//
//  DTMemoryStorage+DTCollectionViewManagerAdditions.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.08.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <DTModelStorage/DTMemoryStorage.h>

#pragma clang assume_nonnull begin

/**
 Category, that adds UICollectionView specific methods to DTMemoryStorage.
 */

@interface DTMemoryStorage (DTCollectionViewManagerAdditions)

/**
 Move collection item to `indexPath`.
 
 @param sourceIndexPath source indexPath of item to move.
 
 @param destinationIndexPath Index, where item should be moved.
 
 @warning Moving item at index, that is not valid, won't do anything, except logging into console about failure
 */
-(void)moveCollectionItemAtIndexPath:(NSIndexPath *)sourceIndexPath
                         toIndexPath:(NSIndexPath *)destinationIndexPath;

///---------------------------------------
/// @name Managing sections
///---------------------------------------

/**
 Moves a section to a new location in the collection view. Supplementary models are moved automatically.
 
 @param fromSection The index of the section to move.
 
 @param toSection The index in the collection view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
-(void)moveCollectionViewSection:(NSInteger)fromSection toSection:(NSInteger)toSection;

@end

#pragma clang assume_nonnull end
