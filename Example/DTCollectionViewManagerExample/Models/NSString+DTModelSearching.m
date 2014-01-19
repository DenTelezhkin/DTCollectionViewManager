//
//  NSString+DTModelSearching.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 19.01.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "NSString+DTModelSearching.h"

@implementation NSString (DTModelSearching)

- (BOOL)shouldShowInSearchResultsForSearchString:(NSString*)searchString
                                    inScopeIndex:(int)scope
{
    return [self rangeOfString:searchString].location !=NSNotFound;
}

@end
