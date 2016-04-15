//
// $Id: NSObjectExtensions.h,v 1.1.1.1 1997/12/09 07:18:54 nygard Exp $
//

#import <Foundation/Foundation.h>

@interface NSObject (SNExtentions)

- (void) encodeWithCoder:(NSCoder *)aCoder;
- initWithCoder:(NSCoder *)aDecoder;

@end
