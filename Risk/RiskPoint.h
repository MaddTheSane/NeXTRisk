//
// $Id: RiskPoint.h,v 1.1.1.1 1997/12/09 07:18:56 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

@interface RiskPoint : NSObject <NSCoding>
{
    NSPoint point;
}

+ (instancetype)riskPointWithPoint:(NSPoint)aPoint;
- (instancetype)initWithPoint:(NSPoint)aPoint NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (readonly) NSPoint point;

@end
