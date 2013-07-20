//
//  CollectionViewModelTransfer.h
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 1/24/13.
//  Copyright (c) 2013 MLSDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTCollectionViewModelTransfer
-(void)updateWithModel:(id)model;
@optional
-(id)model;
@end
