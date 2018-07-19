//
//  RKWorldDecoder.m
//  RiskKit
//
//  Created by C.W. Betts on 7/19/18.
//  Copyright © 2018 C.W. Betts. All rights reserved.
//

#import "RKWorldDecoder.h"

@implementation RKWorldDecoder
- (nullable Class)unarchiver:(NSKeyedUnarchiver *)unarchiver cannotDecodeObjectOfClassName:(NSString *)name originalClasses:(NSArray<NSString *> *)classNames
{
    NSString *newClassName = [@"RK" stringByAppendingString:name];
    return NSClassFromString(newClassName);
    
    //return nil;
}

@end
