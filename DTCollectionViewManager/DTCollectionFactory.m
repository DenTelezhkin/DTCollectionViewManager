//
//  DTCollectionFactory.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTCollectionFactory.h"

static NSString *const DTSupplementaryFallbackReuseIdentifier = @"FallbackSupplementaryReuseIdentifier";

@implementation DTCollectionFactory

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:cellClass];
    
    NSString * reuseIdentifier = [self reuseIdentifierForClass:modelClass];
    NSString * cellClassString = NSStringFromClass(cellClass);
   
    if ([self nibExistsWithNibName:cellClassString])
    {
        [[self.delegate collectionView] registerNib:[UINib nibWithNibName:cellClassString
                                                                   bundle:nil]
                         forCellWithReuseIdentifier:reuseIdentifier];
    }
    else {
        [[self.delegate collectionView] registerClass:cellClass
                           forCellWithReuseIdentifier:reuseIdentifier];
    }
}

-(void)registerSupplementaryClass:(Class)supplementaryClass
                          forKind:(NSString *)kind
                    forModelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:supplementaryClass];
    
    NSString * reuseIdentifier = [self reuseIdentifierForClass:modelClass];
    NSString * supplementaryClassString = NSStringFromClass(supplementaryClass);
    
    [[self.delegate collectionView] registerClass:supplementaryClass
                       forSupplementaryViewOfKind:kind
                              withReuseIdentifier:reuseIdentifier];
    
    if ([self nibExistsWithNibName:supplementaryClassString])
    {
        [[self.delegate collectionView] registerNib:[UINib nibWithNibName:supplementaryClassString
                                                                   bundle:nil]
                         forSupplementaryViewOfKind:kind
                                withReuseIdentifier:reuseIdentifier];
    }
}

-(UICollectionViewCell <DTCollectionViewModelTransfer> *)cellForItem:(id)modelItem
                                                         atIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseIdentifier = [self reuseIdentifierForClass:[modelItem class]];
    if (!reuseIdentifier)
    {
        return nil;
    }
    else {
        return [[self.delegate collectionView]
                dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                          forIndexPath:indexPath];
    }
}

-(UICollectionReusableView <DTCollectionViewModelTransfer> *)supplementaryViewOfKind:(NSString *)kind
                                             forItem:(id)modelItem
                                         atIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseIdentifier = [self reuseIdentifierForClass:[modelItem class]];
    if (!reuseIdentifier)
    {
        return nil;
    }
    else {
        return [[self.delegate collectionView]
                dequeueReusableSupplementaryViewOfKind:kind
                withReuseIdentifier:reuseIdentifier
                forIndexPath:indexPath];
    }
}

-(UICollectionReusableView *)emptySupplementaryViewOfKind:(NSString *)kind
                                             forIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseIdentifier = DTSupplementaryFallbackReuseIdentifier;
    [[self.delegate collectionView] registerClass:[UICollectionReusableView class]
                       forSupplementaryViewOfKind:kind
                              withReuseIdentifier:reuseIdentifier];
    
    return [[self.delegate collectionView] dequeueReusableSupplementaryViewOfKind:kind
                                                              withReuseIdentifier:reuseIdentifier
                                                                     forIndexPath:indexPath];
}

- (NSString *)reuseIdentifierForClass:(Class)class
{
    NSString * classString = NSStringFromClass(class);
    
    if ([classString isEqualToString:@"__NSCFConstantString"] ||
        [classString isEqualToString:@"__NSCFString"] ||
        class == [NSMutableString class])
    {
        return @"NSString";
    }
    if ([classString isEqualToString:@"__NSCFNumber"] ||
        [classString isEqualToString:@"__NSCFBoolean"])
    {
        return @"NSNumber";
    }
    if ([classString isEqualToString:@"__NSDictionaryI"] ||
        [classString isEqualToString:@"__NSDictionaryM"] ||
        class == [NSMutableDictionary class])
    {
        return @"NSDictionary";
    }
    if ([classString isEqualToString:@"__NSArrayI"] ||
        [classString isEqualToString:@"__NSArrayM"] ||
        class == [NSMutableArray class])
    {
        return @"NSArray";
    }
    return classString;
}

-(BOOL)nibExistsWithNibName:(NSString *)nibName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:nibName
                                                     ofType:@"nib"];
    if (path)
    {
        return YES;
    }
    return NO;
}

-(void)checkClassForModelTransferProtocolSupport:(Class)class
{
    if (![class conformsToProtocol:@protocol(DTCollectionViewModelTransfer)])
    {
        NSString * reason = [NSString stringWithFormat:@"class %@ should conform\n"
                             "to DTCollectionViewModelTransfer protocol",
                             NSStringFromClass(class)];
        NSException * exc =
        [NSException exceptionWithName:@"DTCollectionViewManager API exception"
                                reason:reason
                              userInfo:nil];
        [exc raise];
    }
}

@end
