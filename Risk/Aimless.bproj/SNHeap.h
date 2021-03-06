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

NS_ASSUME_NONNULL_BEGIN

@interface SNHeap<__covariant ObjectType> : NSObject <NSFastEnumeration>
{
    NSComparisonResult (*comparator_function)(ObjectType, ObjectType, void *);
    void *context;
    id __strong *  data;
    NSInteger current_size;
    NSInteger maximum_size;
}

// Private

- (void) heapify:(NSInteger)i;

// Public

+ (instancetype)heapUsingFunction:(NSComparisonResult (*)(ObjectType, ObjectType, void *__nullable))comparator context:(nullable void *)aContext;

- (instancetype)initUsingFunction:(NSComparisonResult (*)(ObjectType, ObjectType, void *__nullable))comparator context:(nullable void *)aContext NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (void) insertObject:(ObjectType)anObject;
- (void) insertObjectsFromEnumerator:(NSEnumerator<ObjectType> *)objectEnumerator;
- (nullable ObjectType)extractObject;
@property (readonly, strong, nullable) ObjectType firstObject;

- (void) removeAllObjects;

@property (readonly) NSInteger count;

- (void) heapifyFromObject:(ObjectType)anObject;
- (void) removeObject:(ObjectType)anObject;

@end

NS_ASSUME_NONNULL_END
