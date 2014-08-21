//
//  DTCoreDataStorage+DTCollectionViewManagerAdditions.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.08.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTCoreDataStorage+DTCollectionViewManagerAdditions.h"

@implementation DTCoreDataStorage (DTCollectionViewManagerAdditions)

-(id)supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSUInteger)sectionNumber
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        id <NSFetchedResultsSectionInfo> section = [self.fetchedResultsController sections][sectionNumber];
        return section.name;
    }
    return nil;
}

@end
