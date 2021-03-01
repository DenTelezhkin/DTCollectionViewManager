//
//  SwiftTryCatch.h
//  Tests-iOS
//
//  Created by Denys Telezhkin on 01.03.2021.
//  Copyright © 2021 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwiftTryCatch : NSObject

+ (void)tryBlock:(void(^)(void))tryBlock catchBlock:(void(^)(NSException*exception))catchBlock finallyBlock:(void(^)(void))finallyBlock;

@end

NS_ASSUME_NONNULL_END
