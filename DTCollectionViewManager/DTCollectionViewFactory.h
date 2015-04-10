//
//  DTCollectionFactory.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
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

#import <DTModelStorage/DTModelTransfer.h>

#pragma clang assume_nonnull begin

/**
 Protocol, used by DTCollectionFactory to access collectionView property on DTCollectionViewController instance.
 */
@protocol DTCollectionFactoryDelegate
- (UICollectionView *)collectionView;
@end

/**
 `DTCollectionFactory` is a cell/supplementary view factory, that is used by DTCollectionViewController.
 
 This class is intended to be used internally by DTCollectionViewController. You shouldn't call any of it's methods.
 */

@interface DTCollectionViewFactory : NSObject

- (void)registerCellClass:(Class)cellClass
            forModelClass:(Class)modelClass;

- (void)registerNibNamed:(NSString *)nibName
            forCellClass:(Class)cellClass
           forModelClass:(Class)modelClass;

- (void)registerSupplementaryClass:(Class)supplementaryClass
                           forKind:(NSString *)kind
                     forModelClass:(Class)modelClass;

- (void)registerNibNamed:(NSString *)nibName
   forSupplementaryClass:(Class)supplementaryClass
                 forKind:(NSString *)kind
           forModelClass:(Class)modelClass;

- (UICollectionViewCell <DTModelTransfer> *)cellForItem:(id)modelItem
                                            atIndexPath:(NSIndexPath *)indexPath;

- (nullable UICollectionReusableView <DTModelTransfer> *)supplementaryViewOfKind:(NSString *)kind
                                                                         forItem:(id)modelItem
                                                                     atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, weak) id <DTCollectionFactoryDelegate> delegate;
@end

#pragma clang assume_nonnull end
