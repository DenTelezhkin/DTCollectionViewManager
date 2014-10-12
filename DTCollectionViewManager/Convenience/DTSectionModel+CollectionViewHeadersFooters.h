//
//  DTSectionModel+CollectionViewHeadersFooters.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTSectionModel.h"

/**
 Convenience category for section headers and footers in UICollectionViewFlowLayout.
 */

@interface DTSectionModel (CollectionViewHeadersFooters)

/**
 Retrieve collection header model for current section.
 
 @return header model
 */
-(id)collectionHeaderModel;

/**
 Retrieve collection header model for current section.
 
 @return footer model
 */
-(id)collectionFooterModel;

/**
 Header model for current section.
 
 @param headerModel footer model for current section
 */
-(void)setCollectionSectionHeader:(id)headerModel;

/**
 Footer model for current section.
 
 @param footerModel footer model for current section
 */
-(void)setCollectionSectionFooter:(id)footerModel;

@end
