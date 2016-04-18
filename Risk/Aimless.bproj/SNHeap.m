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

#import "Risk.h"

RCSID ("$Id: SNHeap.m,v 1.1.1.1 1997/12/09 07:19:16 nygard Exp $");

#import "SNHeap.h"

static inline NSInteger SNLeftIndex (NSInteger n)
{
    return 2 * n + 1;
}

//----------------------------------------------------------------------

static inline NSInteger SNRightIndex (NSInteger n)
{
    return 2 * n + 2;
}

//----------------------------------------------------------------------

static inline NSInteger SNParentIndex (NSInteger n)
{
    return (n - 1) / 2;
}

//----------------------------------------------------------------------

@implementation SNHeap

//----------------------------------------------------------------------

+ (instancetype) heapUsingFunction:(NSComparisonResult (*)(id,id,void *))comparator context:(void *)aContext
{
    SNHeap *newHeap;
    
    newHeap = [[[SNHeap alloc] initUsingFunction:comparator context:aContext] autorelease];
    
    return newHeap;
}

//----------------------------------------------------------------------

- (instancetype) initUsingFunction:(NSComparisonResult (*)(id, id, void *))comparator context:(void *)aContext
{
    if (self = [super init]) {
        comparator_function = comparator;
        context = aContext;
        maximum_size = 8;
        
        data = (id *)malloc (maximum_size * sizeof (id));
        NSAssert (data != NULL, @"Malloc() failed.");
        current_size = 0;
    }
    
    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    int l;
    
    if (data != NULL)
    {
        for (l = 0; l < current_size; l++)
        {
            [data[l] autorelease];
        }
        
        free (data);
    }
    
    [super dealloc];
}

//----------------------------------------------------------------------

// -1: NSOrderedAscending
//  0:
//  1: NSOrderedDescending

- (void) heapify:(NSInteger)i
{
    NSInteger l;
    NSInteger r;
    NSInteger smallest;
    
    l = SNLeftIndex (i);
    r = SNRightIndex (i);
    
    if (l < current_size && comparator_function (data[l], data[i], context) == NSOrderedAscending)
        smallest = l;
    else
        smallest = i;
    
    if (r < current_size && comparator_function (data[r], data[smallest], context) == NSOrderedAscending)
        smallest = r;
    
    if (smallest != i)
    {
        id tmp = data[i];
        data[i] = data[smallest];
        data[smallest] = tmp;
        
        [self heapify:smallest];
    }
}

//----------------------------------------------------------------------

- (void) insertObject:anObject
{
    NSInteger i;
    id current;
    id parent;
    
    //NSLog (@"before: current: %d, maximum: %d", current_size, maximum_size);
    if (current_size >= maximum_size)
    {
        // increase size
        id *tmp = (id *)malloc (maximum_size * 2 * sizeof (id));
        
        NSAssert (tmp != NULL, @"Could not malloc() additional memory");
        memcpy (tmp, data, current_size * sizeof (id *));
        free (data);
        data = tmp;
        maximum_size *= 2;
    }
    //NSLog (@" after: current: %d, maximum: %d", current_size, maximum_size);
    
    NSAssert (current_size < maximum_size, @"Too big!");
    
    [anObject retain];
    
    i = current_size++;
    current = data[i] = anObject;
    parent = data[SNParentIndex (i)];
    
    while (i > 0 && comparator_function (parent, current, context) == NSOrderedDescending)
    {
        data[i] = parent;
        i = SNParentIndex (i);
        parent = data[SNParentIndex (i)];
    }
    
    data[i] = current;
}

//----------------------------------------------------------------------

- (void) insertObjectsFromEnumerator:(NSEnumerator *)objectEnumerator
{
    id object;
    
    while (object = [objectEnumerator nextObject])
    {
        [self insertObject:object];
    }
}

//----------------------------------------------------------------------

// Return nil if there are no more objects.
- extractObject
{
    id min;
    
    if (current_size > 0)
    {
        min = data[0];
        data[0] = data[current_size - 1];
        current_size--;
        [self heapify:0];
        
        [min autorelease];
    }
    else
    {
        min = nil;
    }
    
    return min;
}

//----------------------------------------------------------------------

- firstObject
{
    id min;
    
    if (current_size > 0)
        min = data[0];
    else
        min = nil;
    
    return min;
}

//----------------------------------------------------------------------

// Cheezy method -- need to redo

- (void) removeAllObjects
{
    while (current_size > 0)
    {
        [self extractObject];
    }
}

//----------------------------------------------------------------------

- (NSInteger) count
{
    return current_size;
}

//----------------------------------------------------------------------

- (void) heapifyFromObject:anObject
{
    NSInteger l;
    
    for (l = 0; l < current_size; l++)
    {
        if (data[l] == anObject)
        {
            NSLog (@"Heapifying from %ld", (long)l);
            [self heapify:l];
            break;
        }
    }
}

//----------------------------------------------------------------------

- (void) removeObject:anObject
{
    NSInteger l;
    
    for (l = 0; l < current_size; l++)
    {
        if (data[l] == anObject)
        {
            current_size--;
            data[l] = data[current_size];
            [self heapify:l];
            break;
        }
    }
}

//----------------------------------------------------------------------

- (NSString *) description
{
    NSMutableArray *array;
    NSInteger l;
    
    array = [NSMutableArray array];
    for (l = 0; l < current_size; l++)
        [array addObject:data[l]];
    
    return array.description;
}

@end
