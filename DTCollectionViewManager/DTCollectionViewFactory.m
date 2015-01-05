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
#import "DTRuntimeHelper.h"

@interface DTCollectionViewFactory()
@property (nonatomic, strong) NSMutableDictionary * cellMappings;
@property (nonatomic, strong) NSMutableDictionary * supplementaryMappings;

@end

@implementation DTCollectionViewFactory

-(NSMutableDictionary *)cellMappings
{
    if (!_cellMappings)
        _cellMappings = [NSMutableDictionary dictionary];
    return _cellMappings;
}

-(NSMutableDictionary * )supplementaryMappings
{
    if (!_supplementaryMappings)
    {
        _supplementaryMappings = [NSMutableDictionary dictionary];
    }
    return _supplementaryMappings;
}

-(void)setSupplementaryClass:(Class)supplementaryClass forKind:(NSString *)kind forModelClass:(Class)modelClass
{
    NSMutableDictionary * kindMappings = self.supplementaryMappings[kind];
    if (!kindMappings)
    {
        kindMappings = [NSMutableDictionary dictionary];
        self.supplementaryMappings[kind] = kindMappings;
    }
    kindMappings[[DTRuntimeHelper modelStringForClass:modelClass]] = [DTRuntimeHelper classStringForClass:supplementaryClass];
}

- (void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    NSString * cellClassString = [DTRuntimeHelper classStringForClass:cellClass];
    if ([self nibExistsWithNibName:cellClassString])
    {
        [[self.delegate collectionView] registerNib:[UINib nibWithNibName:cellClassString
                                                                   bundle:[NSBundle bundleForClass:[self class]]]
                         forCellWithReuseIdentifier:[DTRuntimeHelper classStringForClass:cellClass]];
    }
    self.cellMappings[[DTRuntimeHelper modelStringForClass:modelClass]] = [DTRuntimeHelper classStringForClass:cellClass];
}

- (void)registerNibNamed:(NSString *)nibName forCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    NSParameterAssert([self nibExistsWithNibName:nibName]);
    
    [[self.delegate collectionView] registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle bundleForClass:[self class]]]
                     forCellWithReuseIdentifier:[DTRuntimeHelper classStringForClass:cellClass]];
    self.cellMappings[[DTRuntimeHelper modelStringForClass:modelClass]] = NSStringFromClass(cellClass);
}

- (void)registerSupplementaryClass:(Class)supplementaryClass
                           forKind:(NSString *)kind
                     forModelClass:(Class)modelClass
{
    NSString * supplementaryClassString = [DTRuntimeHelper classStringForClass:supplementaryClass];

    if ([self nibExistsWithNibName:supplementaryClassString])
    {
        [[self.delegate collectionView] registerNib:[UINib nibWithNibName:supplementaryClassString
                                                                   bundle:[NSBundle bundleForClass:[self class]]]
                         forSupplementaryViewOfKind:kind
                                withReuseIdentifier:supplementaryClassString];
    }
    [self setSupplementaryClass:supplementaryClass
                        forKind:kind
                  forModelClass:modelClass];
}

- (void)registerNibNamed:(NSString *)nibName
   forSupplementaryClass:(Class)supplementaryClass
                 forKind:(NSString *)kind
           forModelClass:(Class)modelClass
{
    NSParameterAssert([self nibExistsWithNibName:nibName]);
    
    [[self.delegate collectionView] registerNib:[UINib nibWithNibName:nibName
                                                               bundle:[NSBundle bundleForClass:[self class]]]
                     forSupplementaryViewOfKind:kind
                            withReuseIdentifier:[DTRuntimeHelper classStringForClass:supplementaryClass]];
    
    [self setSupplementaryClass:supplementaryClass
                        forKind:kind
                  forModelClass:modelClass];
}

- (UICollectionViewCell <DTModelTransfer> *)cellForItem:(id)modelItem
                                            atIndexPath:(NSIndexPath *)indexPath
{
    NSString * classString = self.cellMappings[[DTRuntimeHelper modelStringForClass:[modelItem class]]];
    return [[self.delegate collectionView]
                dequeueReusableCellWithReuseIdentifier:classString
                                          forIndexPath:indexPath];
}

- (UICollectionReusableView <DTModelTransfer> *)supplementaryViewOfKind:(NSString *)kind
                                                                forItem:(id)modelItem
                                                            atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * kindMappings = self.supplementaryMappings[kind];
    NSString * cellClassString  = kindMappings[[DTRuntimeHelper modelStringForClass:[modelItem class]]];
    if (!cellClassString)
    {
        return nil;
    }
    else
    {
        return [[self.delegate collectionView]
                dequeueReusableSupplementaryViewOfKind:kind
                                   withReuseIdentifier:cellClassString
                                          forIndexPath:indexPath];
    }
}

- (BOOL)nibExistsWithNibName:(NSString *)nibName
{
    NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:nibName
                                                                       ofType:@"nib"];
    if (path)
    {
        return YES;
    }
    return NO;
}

@end
