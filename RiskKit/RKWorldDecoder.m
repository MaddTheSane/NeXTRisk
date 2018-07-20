//
//  RKWorldDecoder.m
//  RiskKit
//
//  Created by C.W. Betts on 7/19/18.
//  Copyright © 2018 C.W. Betts. All rights reserved.
//

#import "RKWorldDecoder.h"
#import "RKNeighbor.h"
#import "RKCard.h"

@implementation RKWorldDecoder
- (nullable Class)unarchiver:(NSKeyedUnarchiver *)unarchiver cannotDecodeObjectOfClassName:(NSString *)name originalClasses:(NSArray<NSString *> *)classNames
{
    if ([name isEqualToString:@"RiskCard"]) {
        return [RKCard class];
    }
    if ([name isEqualToString:@"RiskNeighbor"]) {
        return [RKNeighbor class];
    }

    NSString *newClassName = [@"RK" stringByAppendingString:name];
    return NSClassFromString(newClassName);
    
    //return nil;
}

@end
