#import "Risk.h"

RCSID ("$Id: NSObjectExtensions.m,v 1.2 1997/12/15 07:43:56 nygard Exp $");

#import "NSObjectExtensions.h"

//======================================================================
// Provide implementations so that all objects can always call super
// with the same method name.
//======================================================================

@implementation NSObject (SNExtentions)

- (void) encodeWithCoder:(NSCoder *)aCoder
{
}

//----------------------------------------------------------------------

- initWithCoder:(NSCoder *)aDecoder
{
    return self;
}

@end
