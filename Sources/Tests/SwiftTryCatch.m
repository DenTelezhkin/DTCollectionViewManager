//
//  SwiftTryCatch.m
//  Tests-iOS
//
//  Created by Denys Telezhkin on 01.03.2021.
//  Copyright © 2021 Denys Telezhkin. All rights reserved.
//

#import "SwiftTryCatch.h"

@implementation SwiftTryCatch

+ (void)tryBlock:(void(^)(void))tryBlock catchBlock:(void(^)(NSException*exception))catchBlock finallyBlock:(void(^)(void))finallyBlock {
    @try {
        tryBlock ? tryBlock() : nil;
    }
    
    @catch (NSException *exception) {
        catchBlock ? catchBlock(exception) : nil;
    }
    @finally {
        finallyBlock ? finallyBlock() : nil;
    }
}

@end
