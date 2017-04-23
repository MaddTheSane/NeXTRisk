//
// $Id: DNode.h,v 1.1.1.1 1997/12/09 07:19:16 nygard Exp $
//

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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Good enough for now.
#define D_INFINITY 1000000

// Transient for now, so we won't retain previous...

//----------------------------------------------------------------------
// Keep track of the distance and previous step in the path, so that
// we can buid the shortest path.
//----------------------------------------------------------------------

@interface DNode : NSObject
{
    NSInteger distance;
    __unsafe_unretained id previous;
}

+ (instancetype)dNode;

- (instancetype)init;

@property (readonly, assign, nullable) id previous;

@property NSInteger distance;
- (void) setDistance:(NSInteger)newDistance withPrevious:(nullable id)newPrevious;

- (void) relaxFrom:(id)source distance:(NSInteger)x;

@end

NS_ASSUME_NONNULL_END
