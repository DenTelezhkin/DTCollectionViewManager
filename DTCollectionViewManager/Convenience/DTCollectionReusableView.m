//
//  DTCollectionReusableView.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 03.08.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionReusableView.h"

@implementation DTCollectionReusableView

-(void)updateWithModel:(id)model
{
    NSString * reason = [NSString stringWithFormat:@"view %@ should implement updateWithModel: method\n",
                         NSStringFromClass([self class])];
    NSException * exc =
    [NSException exceptionWithName:@"DTCollectionViewManager API exception"
                            reason:reason
                          userInfo:nil];
    [exc raise];
}

-(id)model
{
    return nil;
}

@end
