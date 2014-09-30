//
//  DTCollectionViewControllerEvents.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 30.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTCollectionViewControllerEvents <NSObject>

@optional

// updating content

- (void)collectionControllerWillUpdateContent;
- (void)collectionControllerDidUpdateContent;

// searching

- (void)collectionControllerWillBeginSearch;
- (void)collectionControllerDidEndSearch;
- (void)collectionControllerDidCancelSearch;

@end
