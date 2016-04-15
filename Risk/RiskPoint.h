//
// $Id: RiskPoint.h,v 1.1.1.1 1997/12/09 07:18:56 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

@interface RiskPoint : NSObject
{
    NSPoint point;
}

+ (void) initialize;

+ riskPointWithPoint:(NSPoint)aPoint;

- initWithPoint:(NSPoint)aPoint;

- (void) encodeWithCoder:(NSCoder *)aCoder;
- initWithCoder:(NSCoder *)aDecoder;

- (NSPoint) point;
- (NSString *) description;

@end
