// Card.h
// Part of Risk by Mike Ferris

#import <objc/Object.h>

#define NIL_TYPE		-1
#define SOLDIER_TYPE	0
#define CANNON_TYPE		1
#define CAVALRY_TYPE	2

@interface Card:Object
{
	int countryNum;
	int type;
	id image;
	
}

+ initialize;

- init;
- initCountry:(int)c type:(int)t imageFile:(const char *)imageName;
- free;

- (int)countryNum;
- (int)type;
- image;

- setCountryNum:(int)c;
- setType:(int)t;
- setImageName:(const char *)imageName;

@end
