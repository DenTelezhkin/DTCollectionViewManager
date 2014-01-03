//
//  DTCollectionFactory.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 21.07.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
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

#import "DTCollectionViewFactory.h"

static NSString *const DTSupplementaryFallbackReuseIdentifier = @"FallbackSupplementaryReuseIdentifier";

@implementation DTCollectionViewFactory

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
}

-(void)registerSupplementaryClass:(Class)supplementaryClass
                          forKind:(NSString *)kind
                    forModelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:supplementaryClass];
    
    NSString * reuseIdentifier = [self reuseIdentifierForClass:modelClass];
    NSString * supplementaryClassString = NSStringFromClass(supplementaryClass);
    
    if ([self nibExistsWithNibName:supplementaryClassString])
    {
        [[self.delegate collectionView] registerNib:[UINib nibWithNibName:supplementaryClassString
                                                                   bundle:nil]
                         forSupplementaryViewOfKind:kind
                                withReuseIdentifier:reuseIdentifier];
    }
}

-(UICollectionViewCell <DTModelTransfer> *)cellForItem:(id)modelItem
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

-(UICollectionReusableView <DTModelTransfer> *)supplementaryViewOfKind:(NSString *)kind
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
    if (![class conformsToProtocol:@protocol(DTModelTransfer)])
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
