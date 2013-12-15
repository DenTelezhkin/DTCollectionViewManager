//
//  DTCollectionViewMemoryStorage.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionViewMemoryStorage.h"
#import "DTCollectionViewSection.h"
@implementation DTCollectionViewMemoryStorage

+(instancetype)storage
{
    DTCollectionViewMemoryStorage * storage = [self new];
    
    storage.sections = [NSMutableArray array];
    
    return storage;
}

-(id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    id <DTCollectionViewSection> sectionModel = [self sections][indexPath.section];
    return [sectionModel.objects objectAtIndex:indexPath.row];
}

@end
