//
//  DTSectionModel+CollectionViewHeadersFooters.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <DTModelStorage/DTSectionModel.h>

#if __has_feature(nullability) // Xcode 6.3+
#pragma clang assume_nonnull begin
#else
#define nullable
#define __nullable
#endif

/**
 Convenience category for section headers and footers in UICollectionViewFlowLayout.
 */

@interface DTSectionModel (CollectionViewHeadersFooters)

/**
 Retrieve collection header model for current section.
 
 @return header model
 */
-(nullable id)collectionHeaderModel;

/**
 Retrieve collection header model for current section.
 
 @return footer model
 */
-(nullable id)collectionFooterModel;

/**
 Header model for current section.
 
 @param headerModel footer model for current section
 */
-(void)setCollectionSectionHeader:(nullable id)headerModel;

/**
 Footer model for current section.
 
 @param footerModel footer model for current section
 */
-(void)setCollectionSectionFooter:(nullable id)footerModel;

@end

#if __has_feature(nullability)
#pragma clang assume_nonnull end
#endif
