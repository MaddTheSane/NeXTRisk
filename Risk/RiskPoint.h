//
// $Id: RiskPoint.h,v 1.1.1.1 1997/12/09 07:18:56 nygard Exp $
// This file is a part of Risk by Mike Ferris.
//

#import <Foundation/Foundation.h>

/// A RiskPoint can be encoded on a stream and stored in arrays.
@interface RiskPoint : NSObject <NSCoding>

+ (instancetype)riskPointWithPoint:(NSPoint)aPoint NS_SWIFT_UNAVAILABLE("Use init(point:) instead");
- (instancetype)initWithPoint:(NSPoint)aPoint NS_DESIGNATED_INITIALIZER;

@property (readonly) NSPoint point;

@end
