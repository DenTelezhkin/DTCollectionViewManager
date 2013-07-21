//
//  DTCollectionFactory.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTCollectionFactoryDelegate
-(UICollectionView *)collectionView;
@end

@interface DTCollectionFactory : NSObject

-(void)registerCellClass:(Class)cellClass
           forModelClass:(Class)modelClass;

-(void)registerSupplementaryClass:(Class)supplementaryClass
                          forKind:(NSString *)kind
                    forModelClass:(Class)modelClass;

-(UICollectionViewCell *)cellForItem:(id)modelItem;
-(UICollectionReusableView *)supplementaryViewForItem:(id)modelItem;

@property (nonatomic, weak) id <DTCollectionFactoryDelegate> delegate;
@end
