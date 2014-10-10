//
//  DTCollectionViewControllerEvents.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 30.09.14.
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

#import <Foundation/Foundation.h>

/**
 Protocol, that allows you to react to different DTCollectionViewController events. This protocol is adopted by DTCollectionViewController instance.
 */
@protocol DTCollectionViewControllerEvents <NSObject>

@optional

// updating content

/**
 This method will be called every time after storage contents changed, and just before UI will be updated with these changes.
 */
- (void)collectionControllerWillUpdateContent;

/**
 This method will be called every time after storage contents changed, and after UI has been updated with these changes.
 */
- (void)collectionControllerDidUpdateContent;

// searching

/**
 This method is called when DTCollectionViewController will start searching in current storage. After calling this method DTCollectionViewController starts using searchingDataStorage instead of dataStorage to provide search results.
 */
- (void)collectionControllerWillBeginSearch;

/**
 This method is called after DTCollectionViewController ended searching in storage and updated UITableView UI.
 */
- (void)collectionControllerDidEndSearch;

/**
 This method is called, when search string becomes empty. DTCollectionViewController switches to default storage instead of searchingDataStorage and reloads data of the UICollectionView.
 */
- (void)collectionControllerDidCancelSearch;

@end
