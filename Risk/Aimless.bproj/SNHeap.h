//
// $Id: SNHeap.h,v 1.1.1.1 1997/12/09 07:19:16 nygard Exp $
//

//
//  This file is a part of Empire, a game of exploration and conquest.
//  Copyright (C) 1996  Steve Nygard
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

@interface SNHeap : NSObject
{
    NSComparisonResult (*comparator_function)(id, id, void *);
    void *context;
    id *data;
    int current_size;
    int maximum_size;
}

// Private

- (void) heapify:(int)i;

// Public

+ heapUsingFunction:(NSComparisonResult (*)(id,id,void *))comparator context:(void *)aContext;

- initUsingFunction:(NSComparisonResult (*)(id, id, void *))comparator context:(void *)aContext;
- (void) dealloc;
- (void) insertObject:anObject;
- (void) insertObjectsFromEnumerator:(NSEnumerator *)objectEnumerator;
- extractObject;
- firstObject;

- (void) removeAllObjects;

- (int) count;

- (void) heapifyFromObject:anObject;
- (void) removeObject:anObject;

- (NSString *) description;

@end
