//
//  This file is a part of Risk by Mike Ferris.
//  Copyright (C) 1997  Steve Nygard
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
//  You may contact the author by:
//     e-mail:  nygard@telusplanet.net
//

#import "../Risk.h"

RCSID ("$Id: DNode.m,v 1.1.1.1 1997/12/09 07:19:16 nygard Exp $");

#import "DNode.h"

@implementation DNode
@synthesize distance;
@synthesize previous;

+ dNode
{
    return [[[DNode alloc] init] autorelease];
}

//----------------------------------------------------------------------

- init
{
    if (self = [super init]) {
        distance = D_INFINITY;
        previous = nil;
    }
    
    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    [super dealloc];
}

//----------------------------------------------------------------------

- (void) setDistance:(NSInteger)newDistance withPrevious:(id)newPrevious
{
    distance = newDistance;
    previous = newPrevious;
}

//----------------------------------------------------------------------

- (void) relaxFrom:source distance:(NSInteger)x
{
    NSInteger aDistance;

    NSAssert (source != nil, @"Source was nil.");

    aDistance = [source distance] + x;

    if (distance > aDistance)
    {
        previous = source;
        distance = aDistance;
    }
}

//----------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<DNode: distance = %ld>", (long)distance];
}

@end
