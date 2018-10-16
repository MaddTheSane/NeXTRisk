// Country.h
// Part of Risk by Mike Ferris

#import <objc/Object.h>
#import <appkit/color.h>
#import <appkit/graphics.h>

@interface Country:Object
{
	NXCoord *shape, *shape2, *shape3;
	int shapePts, shape2Pts, shape3Pts;
	int *neighbors, neighborNum;
	char *name;
	int idNum;
	int player, armies;
	NXPoint armyCellPt;
	NXRect bounds;
	int turn;
	int unmovableArmies;
}

+ initialize;

- initName:(const char *)nm idNum:(int)id shape:(NXCoord *)s shapePts:(int)sPts 
			neighbors:(int *)ne neighborNum:(int)nNum;
- initName:(const char *)nm idNum:(int)id;
- init;

- free;

- windowServerInit;

- drawSelfInView:view withColor:(NXColor)color isSelected:(BOOL)sel;
- (BOOL)ptInCountry:(NXPoint *)pt;

- setPlayer:(int)p andArmies:(int)a;
- (BOOL)isNeighborTo:(int)cNum;
- (char *)name;
- (int)idNum;
- (int)player;
- (int)armies;
- (int)movableArmiesForTurn:(int)tNum;
- (int *)getNeighborsCount:(int *)c;

- getBounds:(NXRect *)b;
- setBounds:(NXRect *)b;
- calcBounds;
- setShape:(NXCoord *)s1 shapePts:(int)sPts 
	 shape2:(NXCoord *)s2 shape2Pts:(int)s2Pts 
	 shape3:(NXCoord *)s3 shape3Pts:(int)s3Pts; 
- setNeighbors:(int *)ne neighborNum:(int)nNum;
- setName:(const char *)nm;
- setIdNum:(int)id;
- setPlayer:(int)p;
- setArmies:(int)a;
- addArmies:(int)a;
- subArmies:(int)a;
- addUnmovableArmies:(int)aNum forTurn:(int)tNum;

- setArmyCellPtX:(NXCoord)x andY:(NXCoord)y;

- invalidateSelfInView:view;

- write:(NXTypedStream *)typedStream;
- read:(NXTypedStream *)typedStream;

@end
