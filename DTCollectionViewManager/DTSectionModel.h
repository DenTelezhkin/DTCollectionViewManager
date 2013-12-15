//
//  DTCOllectionViewSectionModel.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTSection.h"

@interface DTSectionModel : NSObject <DTSection>

/**
 Table items for current section
 */
@property (nonatomic, strong) NSMutableArray * objects;

/**
 Header model for current section. Header presentation depends on `DTTableViewController` sectionHeaderStyle property.
 */
@property (nonatomic, strong) id headerModel;

@end
