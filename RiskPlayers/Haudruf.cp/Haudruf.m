#import "Haudruf.h"
#import <appkit/NSApplication.h>
#import <appkit/NSForm.h>
#import <appkit/NSButton.h>
#import <appkit/NSText.h>
#import <appkit/NSScrollView.h>
#import <appkit/NSPanel.h>
//#import <objc/List.h>
//#import <appkit/publicWraps.h>
#import <string.h>

#define NIBFILE "Haudruf.cp/Haudruf.nib"
#define SCHEISSE 10
#ifndef MIN
#define MIN(x,y) (x<y)?(x):(y) 
#endif
const int countriesPerContinent[6] = {9, 4, 7, 6, 12, 4};

@implementation Haudruf

+ (void)initialize
{	
	if (self == [Haudruf class])
		[self setVersion:1];
}

- (instancetype)initWithPlayerName:(NSString *)aName number:(Player)number gameManager:(RiskGameManager *)aManager
{
	int i;
    if (self = [super initWithPlayerName:aName number:number gameManager:aManager]) {
        [NSBundle loadNibNamed:@"Haudruf.nib" owner:self];
        for (i=0; i<6; i++)
            gotContinent[i] = NO;
        initialContinent = 1;
    }
    
	return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    /*
     [myPlayerNumForm setIntValue:number at:0];
     [haudrufPanel setBecomeKeyOnlyIfNeeded:YES];
     [haudrufPanel orderFront:self];
*/
}

// *****************subclass responsibilities*********************

- (void)chooseCountry
{
	// choose a random country
	NSArray *unoccList = [gameManager unoccupiedCountries];
	id country;
	
	if ([unoccList count]==0)
		return;
	country = [unoccList objectAtIndex:[rng randomNumberWithMaximum:[unoccList count]-1]];
	[self setNotes:"sent by -yourChooseCountry.  "
					"yourChooseCountry chose a country at random."];
	[self occupyCountry:country];
}

- (void)placeInitialArmies:(int)numArmies
{	
	if (![self calcNumCountriesPerContinent])
	{
		NSRunAlertPanel(@"BUG", @"", NULL,NULL, NULL);
		return;
	}
	round = 0;
	if(numCountriesPerContinent[initialContinent = Australia] >= 2)
		[self placeArmies:numArmies inCountry:[self bestCountryFor:Australia]];
	else if(numCountriesPerContinent[initialContinent = SouthAmerica] >= 2)
		[self placeArmies:numArmies inCountry:[self bestCountryFor:SouthAmerica]];
	else if(numCountriesPerContinent[initialContinent = NorthAmerica] >= 4)
		[self placeArmies:numArmies inCountry:[self bestCountryFor:NorthAmerica]];
	else if(numCountriesPerContinent[initialContinent = Africa] >= 3)
		[self placeArmies:numArmies inCountry:[self bestCountryFor:Africa]];
	else if(numCountriesPerContinent[initialContinent = SouthAmerica] >= 1)
		[self placeArmies:numArmies inCountry:[self bestCountryFor:SouthAmerica]];
	else if(numCountriesPerContinent[initialContinent = Australia] >= 1)
		[self placeArmies:numArmies inCountry:[self bestCountryFor:Australia]];
	else if(numCountriesPerContinent[initialContinent = NorthAmerica] >= 2)
		[self placeArmies:numArmies inCountry:[self bestCountryFor:NorthAmerica]];
	else if(numCountriesPerContinent[initialContinent = Africa] >= 2)
		[self placeArmies:numArmies inCountry:[self bestCountryFor:Africa]];
	else if(numCountriesPerContinent[initialContinent = NorthAmerica] >= 1)
		[self placeArmies:numArmies inCountry:[self bestCountryFor:NorthAmerica]];
	else
		[self placeArmies:numArmies inCountry:[self bestCountryFor:SCHEISSE]];	
	//return self;
}

- yourTurnWithArmies:(int)numArmies andCards:(int)numCards
{
	NSSet<Country *> *mycountries = [self ourCountries];
	id attackCountry = nil;
	int i, numArmiesLeft;
	
	round++;
	turn=0;
	numArmiesLeft = numArmies;
	if ([mycountries count]==0)
		return nil;
	//[mycountries free];
	numArmiesLeft += [self turnInCards];
	
	// Verteidigung vorhandener Kontinente
	
	for (i=0; i<6; i++)
	{
	 	if (gotContinent[i])
			numArmiesLeft -= [self defendContinent:i:numArmiesLeft];
	}
	
	// Stabilisierung
	
	if (numArmiesLeft)
	{
		// Kontinent finden, wo viele armien stehen zum Angriff
		numArmiesLeft -= [self stabilizeContinents:numArmiesLeft];
		// Kontinent finden, der "leicht" erobert werden kann
		numArmiesLeft -= [self conquerContinents:numArmiesLeft];
	}
	
	numArmiesLeft -= [self checkInitialContinent:numArmiesLeft];

	if (numArmiesLeft)
	{
		// armeen in armeenreichstes Land mit Nachbarn
		attackCountry = [self klotzArmies:numArmiesLeft];		
	}
	
	while ((attackCountry = [self findBestVictimFor:attackCountry]))
		;
	[self fortifyPosition];
	return self;
}

- youWereAttacked:country by:(int)player
{
	// do nothing.  these methods are for advanced players only.
	// but we do set the notes and pause if we should.
	[self setNotes:"-youWereAttacked: by: was called."];
	[self clearArgForms];
	[functionCalledForm setStringValue:@""];
	[returnValueForm setStringValue:@""];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	return self;
}

- youLostCountry:country to:(int)player
{
	// do nothing.  these methods are for advanced players only.
	// but we do set the notes and pause if we should.
	[self setNotes:"-youLostCountry: to: was called."];
	[self clearArgForms];
	[functionCalledForm setStringValue:@""];
	[returnValueForm setStringValue:@""];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	return self;
}

// *****************country utilities*********************

- (BOOL)occupyCountry:(Country *)country
{
	BOOL retVal;
	
    //[super occu]
    //[gameManager occ]
	retVal = [super occupyCountry:country];
	[self clearArgForms];
	[functionCalledForm setStringValue:@"(BOOL)occupyCountry:" at:0];
	[args1Form setTitle:@"country" ofColumn:0];
	if (country == nil)  {
		[args1Form setStringValue:@"nil" :0];
	}  else  {
		[args1Form setStringValue:[country countryName] at:0];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************card utilities*********************

- (int)playCards:cardList
{
	int retVal;
	
	retVal = [super playCards:cardList];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(int)playCards:" at:0];
	[args1Form setTitle:@"cardList" ofColumn:0];
	if (cardList == nil)  {
		[args1Form setStringValue:"nil" at:0];
	}  else  {
		[args1Form setStringValue:"list of cards" at:0];
	}
	[returnValueForm setIntValue:retVal at:0];
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************place army utilities*********************

- (BOOL)placeArmies:(int)numArmies inCountry:country
{
	BOOL retVal;
	
    //[super placearmies]
	retVal = [super placeArmies:numArmies inCountry:country];
	[self clearArgForms];
	[functionCalledForm setStringValue:@"(BOOL)placeArmies: inCountry:" at:0];
	[args1Form setTitle:@"numArmies" at:0];
	[args1Form setIntValue:numArmies at:0];
	[args1Form setTitle:@"country" at:1];
	if (country == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[(Country *)country name] at:1];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************attack utilities*********************

- (BOOL)attackOnceFrom:fromCountry to:toCountry 
               victory:(BOOL *)victory fromArmies:(int *)fromArmies
              toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
                 weWin:(BOOL *)wewin
{
	BOOL retVal;
	
	retVal = [super attackOnceFrom:fromCountry to:toCountry 
					victory:victory fromArmies:fromArmies 
					toArmies:toArmies vanquished:vanquished
					weWin:wewin];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)attackOnceFrom: to: victory: " 
					"fromArmies: toArmies: vanquished: weWin:" at:0];
	[args1Form setTitle:"fromCountry" at:0];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:0];
	}  else  {
		[args1Form setStringValue:[(Country *)fromCountry name] at:0];
	}
	[args1Form setTitle:"toCountry" at:1];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[(Country *)toCountry name] at:1];
	}
	[args1Form setTitle:"victory" at:2];
	if (*victory)  {
		[args1Form setStringValue:"YES" at:2];
	}  else  {
		[args1Form setStringValue:"NO" at:2];
	}
	[args1Form setTitle:"fromArmies" at:3];
	[args1Form setIntValue:*fromArmies at:3];
	[args2Form setTitle:"toArmies" at:0];
	[args2Form setIntValue:*toArmies at:0];
	[args2Form setTitle:"vanquished" at:1];
	if (*vanquished)  {
		[args2Form setStringValue:"YES" at:1];
	}  else  {
		[args2Form setStringValue:"NO" at:1];
	}
	[args2Form setTitle:"weWin" at:2];
	if (*wewin)  {
		[args2Form setStringValue:"YES" at:2];
	}  else  {
		[args2Form setStringValue:"NO" at:2];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

- (BOOL)attackTimes:(int)times from:fromCountry to:toCountry 
            victory:(BOOL *)victory fromArmies:(int *)fromArmies
           toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
              weWin:(BOOL *)wewin
{
	BOOL retVal;
	
	retVal = [super attackTimes:times from:fromCountry to:toCountry 
					victory:victory fromArmies:fromArmies 
					toArmies:toArmies vanquished:vanquished
					weWin:wewin];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)attackTimes: from: to: victory: " 
					"fromArmies: toArmies: vanquished: weWin:" at:0];
	[args1Form setTitle:"times" at:0];
	[args1Form setIntValue:times at:0];
	[args1Form setTitle:"fromCountry" at:1];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[(Country *)fromCountry name] at:1];
	}
	[args1Form setTitle:"toCountry" at:2];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:2];
	}  else  {
		[args1Form setStringValue:[(Country *)toCountry name] at:2];
	}
	[args1Form setTitle:"victory" at:3];
	if (*victory)  {
		[args1Form setStringValue:"YES" at:3];
	}  else  {
		[args1Form setStringValue:"NO" at:3];
	}
	[args2Form setTitle:"fromArmies" at:0];
	[args2Form setIntValue:*fromArmies at:0];
	[args2Form setTitle:"toArmies" at:1];
	[args2Form setIntValue:*toArmies at:1];
	[args2Form setTitle:"vanquished" at:2];
	if (*vanquished)  {
		[args2Form setStringValue:"YES" at:2];
	}  else  {
		[args2Form setStringValue:"NO" at:2];
	}
	[args2Form setTitle:"weWin" at:3];
	if (*wewin)  {
		[args2Form setStringValue:"YES" at:3];
	}  else  {
		[args2Form setStringValue:"NO" at:3];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

- (BOOL)attackUntilLeft:(int)untilLeft from:fromCountry to:toCountry 
                victory:(BOOL *)victory fromArmies:(int *)fromArmies
               toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
                  weWin:(BOOL *)wewin
{
	BOOL retVal;
	
	retVal = [super attackUntilLeft:untilLeft from:fromCountry to:toCountry 
					victory:victory fromArmies:fromArmies 
					toArmies:toArmies vanquished:vanquished
					weWin:wewin];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)attackUntilLeft: from: to: "
					"victory: fromArmies: toArmies: vanquished: weWin:" at:0];
	[args1Form setTitle:"untilLeft" at:0];
	[args1Form setIntValue:untilLeft at:0];
	[args1Form setTitle:"fromCountry" at:1];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[(Country *)fromCountry name] at:1];
	}
	[args1Form setTitle:"toCountry" at:2];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:2];
	}  else  {
		[args1Form setStringValue:[(Country *)toCountry name] at:2];
	}
	[args1Form setTitle:"victory" at:3];
	if (*victory)  {
		[args1Form setStringValue:"YES" at:3];
	}  else  {
		[args1Form setStringValue:"NO" at:3];
	}
	[args2Form setTitle:"fromArmies" at:0];
	[args2Form setIntValue:*fromArmies at:0];
	[args2Form setTitle:"toArmies" at:1];
	[args2Form setIntValue:*toArmies at:1];
	[args2Form setTitle:"vanquished" at:2];
	if (*vanquished)  {
		[args2Form setStringValue:"YES" at:2];
	}  else  {
		[args2Form setStringValue:"NO" at:2];
	}
	[args2Form setTitle:"weWin" at:3];
	if (*wewin)  {
		[args2Form setStringValue:"YES" at:3];
	}  else  {
		[args2Form setStringValue:"NO" at:3];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

- (BOOL)attackUntilCantFrom:fromCountry to:toCountry 
                    victory:(BOOL *)victory fromArmies:(int *)fromArmies
                   toArmies:(int *)toArmies vanquished:(BOOL *)vanquished
                      weWin:(BOOL *)wewin
{
	BOOL retVal;
	
	retVal = [super attackUntilCantFrom:fromCountry to:toCountry 
					victory:victory fromArmies:fromArmies 
					toArmies:toArmies vanquished:vanquished
					weWin:wewin];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)attackUntilCantFrom: to: "
					"victory: fromArmies: toArmies: vanquished: weWin:" at:0];
	[args1Form setTitle:"fromCountry" at:0];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:0];
	}  else  {
		[args1Form setStringValue:[(Country *)fromCountry name] at:0];
	}
	[args1Form setTitle:"toCountry" at:1];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[(Country *)toCountry name] at:1];
	}
	[args1Form setTitle:"victory" at:2];
	if (*victory)  {
		[args1Form setStringValue:"YES" at:2];
	}  else  {
		[args1Form setStringValue:"NO" at:2];
	}
	[args1Form setTitle:"fromArmies" at:3];
	[args1Form setIntValue:*fromArmies at:3];
	[args2Form setTitle:"toArmies" at:0];
	[args2Form setIntValue:*toArmies at:0];
	[args2Form setTitle:"vanquished" at:1];
	if (*vanquished)  {
		[args2Form setStringValue:"YES" at:1];
	}  else  {
		[args2Form setStringValue:"NO" at:1];
	}
	[args2Form setTitle:"weWin" at:2];
	if (*wewin)  {
		[args2Form setStringValue:"YES" at:2];
	}  else  {
		[args2Form setStringValue:"NO" at:2];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************post-attack & fortify utilities*********************

- (void)moveAttackingArmies:(int)count between:(Country *)fromCountry :(Country *)toCountry
{
	BOOL retVal;
	
	retVal = [super moveAttackingArmies:numArmies between:fromCountry :toCountry];
	[self clearArgForms];
	[functionCalledForm setStringValue:"(BOOL)moveArmies: from: to:" at:0];
	[args1Form setTitle:"numArmies" at:0];
	[args1Form setIntValue:numArmies at:0];
	[args1Form setTitle:"fromCountry" at:1];
	if (fromCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[fromCountry name] at:1];
	}
	[args1Form setTitle:"toCountry" at:1];
	if (toCountry == nil)  {
		[args1Form setStringValue:"nil" at:1];
	}  else  {
		[args1Form setStringValue:[toCountry name] at:1];
	}
	if (retVal)  {
		[returnValueForm setStringValue:"YES" at:0];
	}  else  {
		[returnValueForm setStringValue:"NO" at:0];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************special haudruf methods*********************

- waitForContinue
{
	NSInteger retVal;
	
	NSBeep();
	if (![haudrufPanel isVisible])
        [haudrufPanel orderFront:self];
	[pauseContinueButton setEnabled:NO];
	retVal = [NSApp runModalFor:haudrufPanel];
	return self;
}

- continueAction:sender
{
	[NSApp stopModal];
	[pauseContinueButton setEnabled:YES];
	return self;
}

- checkAction:sender
{
	if ([sender state] == 1)  {
		[continueButton setEnabled:YES];
	}  else  {
		[continueButton setEnabled:NO];
	}
	return self;
}

- clearArgForms
{
	[args1Form setTitle:"arg1:" at:0];
	[args1Form setTitle:"arg2:" at:1];
	[args1Form setTitle:"arg3:" at:2];
	[args1Form setTitle:"arg4:" at:3];
	[args2Form setTitle:"arg5:" at:0];
	[args2Form setTitle:"arg6:" at:1];
	[args2Form setTitle:"arg7:" at:2];
	[args2Form setTitle:"arg8:" at:3];
	[args1Form setStringValue:"" at:0];
	[args1Form setStringValue:"" at:1];
	[args1Form setStringValue:"" at:2];
	[args1Form setStringValue:"" at:3];
	[args2Form setStringValue:"" at:0];
	[args2Form setStringValue:"" at:1];
	[args2Form setStringValue:"" at:2];
	[args2Form setStringValue:"" at:3];
	return self;
}

- setNotes:(const char *)noteText
{
	[[notesScrollText docView] setText:noteText];
	return self;
}

- (BOOL)calcNumCountriesPerContinent
{
	int i,j,k, numContCountries, numMyCountries, tmp;
	id countryList;
	id mycountries = [self myCountries];
	
	if ((numMyCountries=[mycountries count])==0)
		return NO;
	
	numGotContinents = 0;
	for (i=0; i<6; i++)
	 	numCountriesPerContinent[i] = 0;

	for (i=0; i<6; i++)
	{
		countryList = [self countriesInContinent:i];
		numContCountries = [countryList count];
		for (j=0; j<numMyCountries; j++)
		{
			for (k=0; k<numContCountries; k++)
			{
				if ([[mycountries objectAt:j] idNum] == [[countryList objectAt:k] idNum])
				{
					tmp = numCountriesPerContinent[i]++;
					countriesInContinent[i][tmp] = [[countryList objectAt:k] idNum];
				}
			}
		}
	 	if(numCountriesPerContinent[i] == countriesPerContinent[i])
		{
			gotContinent[i]= YES;
			numGotContinents++;
		}
		[countryList free];
	}
	[mycountries free];
	return YES;
}

- bestCountryFor:(int)continent
{
	id countryList = [self countriesInContinent:continent];
	id retCountry;
	int i;
	
	for (i=0; i<[countryList count]; i++)
	{
		if ([[countryList objectAt:i] idNum] == countriesInContinent[continent][0])
		{
			retCountry = [countryList objectAt:i];
			[countryList free];
			return retCountry;
		}
	}
	[countryList free];
	return nil;
}

- (BOOL)countryInContinent:country :(int)continent
{
	id contlist = [self countriesInContinent:continent];
	int i, num;
	
	num = [contlist count];
	for (i=0; i<num; i++)
	{
		if([[contlist objectAt:i] idNum] == [country idNum])
		{
			[contlist free];
			return YES;
		}
	}
	[contlist free];
	return NO;
}

- (int)turnInCards
{
	id cardSet;
	int temp, numArmies = 0;
	
	cardSet = [self bestSet];
	while (cardSet != nil)  
	{
		temp = [self playCards:cardSet];
		[cardSet free];
		if (temp == -1)  
		{
			NXRunAlertPanel("Debug", "bestSet returned an invalid cardset", 
							"OK", NULL, NULL);
			cardSet=nil;
		}  
		else  
		{
			numArmies += temp;
			cardSet = [self bestSet];
		}
	}
	return numArmies;
}

- (int)defendContinent:(int)continent:(int)armiesLeft
{
//	id maxCountry;
	fprintf(stderr, "defend:%d with:%d\n", continent, armiesLeft);
//	return maxCountry;
//	maxCountry = [self getMaxArmyCountry];

	if (continent == AUSTRALIA)
	{
		fprintf(stderr, "defend Australia:%d with:%d\n", continent, armiesLeft);
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:"Indonesia"]];
		return MIN(armiesLeft,5);
	}
	else if (continent == SOUTH_AMERICA)
	{
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:"Brazil"]];
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:"Venezuela"]];
		return MIN(armiesLeft,5);
	}
	else if (continent == NORTH_AMERICA)
	{
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:"Alaska"]];
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:"Greenland"]];
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:"Central America"]];
		return MIN(armiesLeft,5);
	}
	return 0;
}

- (int)stabilizeContinents:(int)armiesLeft
{
	return 0;
}

- (int)conquerContinents:(int)armiesLeft
{
	return 0;
}

- klotzArmies:(int)armiesLeft
{
	id maxCountry;
	
	[self placeArmies:armiesLeft inCountry:maxCountry=[self getMaxArmyCountry]];
//	fprintf(stderr, "armeen:%d in:%s\n", armiesLeft, [maxCountry name]);
	return maxCountry;
}

- findBestVictimFor:country
{
	id enemyList = [self enemyNeighborsTo:country];
	int i, min=10000, fromArmies, toArmies;
	BOOL victory, weWin, vanquished; 
	id minEnemy=nil;
	
	if ([country armies]<4)
		return nil;
	turn++;
	if (enemyList)
	{
		for (i=[enemyList count]-1;i>=0;i--)  
		{
			if ([[enemyList objectAt:i] armies] < min)
			{
				minEnemy = [enemyList objectAt:i];
				min = [minEnemy armies];
			}
		}	
		if ([self attackUntilLeft:3 from:country to:minEnemy victory:&victory
				fromArmies:&fromArmies toArmies: &toArmies vanquished:&vanquished 
				weWin:&weWin])
			[self moveArmies:fromArmies-((round>25)?4:1) from:country to:minEnemy];
		[enemyList free];
		if ((round > 20) && (turn<10))
		{
			if (enemyList=[self neighborsTo:minEnemy])
			{
				[enemyList free];
				return minEnemy;
			}
		}
	}
	return nil;
}

- fortifyPosition
{
	id tmp, maxCountry;
	
	if ([tmp=[self enemyNeighborsTo:maxCountry=[self getMaxArmyCountry]] count])
	{
		[tmp free];
		return self;
	}
	[tmp free];
	tmp = [self neighborsTo:maxCountry];
//	fprintf(stderr, "armies:%d from:%s to:%s", 
//		[maxCountry armies], [maxCountry name],[[tmp objectAt:1] name]);
	[self moveArmies:[maxCountry armies]-1 from:maxCountry to:[tmp objectAt:[rng randMax:[tmp count]-1]]];
	[tmp free];
	
	return self;
}

- enemyNeighborsTo:country
{
	id en = [self neighborsTo:country];
	int i;
	
//	NXRunAlertPanel("44", NULL, NULL,NULL, NULL);
	for (i=[en count]-1;i>=0;i--)  
	{
		if ([[en objectAt:i] player] == myPlayerNum)  
			[en removeObjectAt:i];
	}
	
	if ([en count]==0)  
	{
		[en free];
		return nil;
	}  
	else 
		return en;
}

- getMaxArmyWithEnemyCountry
{
	id armieCountries;
	int cnt, i, max=0;
	id maxCountry=nil;
	id preventJunk=nil;
	
	if (!(armieCountries=[self myCountriesWithAvailableArmies]))
		armieCountries=[self countryList];
	cnt = [armieCountries count];
	for (i=0; i<cnt; i++)
	{
		// Falls armeen vorhanden und Feinde da
		if( ([[armieCountries objectAt:i] armies] > max) &&
			(preventJunk=[self enemyNeighborsTo:[armieCountries objectAt:i]]))
		{
			max = [[armieCountries objectAt:i] armies];
			maxCountry = [armieCountries objectAt:i];
		}
	}
	[preventJunk free];
	[armieCountries free];	
	return maxCountry;
}

- getMaxArmyCountry
{
	id armieCountries;
	int cnt, i, max=0;
	id maxCountry=nil;
	
	if (!(armieCountries=[self myCountriesWithAvailableArmies]))
		armieCountries=[self countryList];
	cnt = [armieCountries count];
	for (i=0; i<cnt; i++)
	{
		if([[armieCountries objectAt:i] armies] > max)
		{
			max = [[armieCountries objectAt:i] armies];
			maxCountry = [armieCountries objectAt:i];
		}
	}
	[armieCountries free];	
	return maxCountry;
}

- getCountryNamed:(char*)name
{
	id countryList = [self myCountries];
	int i,cnt = [countryList count];
	
	for (i=0; i<cnt; i++)
	{
		if (!strcmp(name, [(Country *)[countryList objectAt:i] name]))
		{
//			fprintf(stderr, "Got:%s Wanted:%s\n",[[countryList objectAt:i] name], name); 
			return [countryList objectAt:i];
		}
	}
	return nil;
}

- (int) checkInitialContinent:(int) numArmies
{
	int i, fromArmies, toArmies;
//	int i, min=10000, fromArmies, toArmies;
	BOOL victory, weWin, vanquished; 
	id minEnemy=nil;

	id maxCountry = [self getMaxArmyCountry];
	
	if (gotContinent[initialContinent])
		return 0;
	if (numCountriesPerContinent[initialContinent] == 0)
		return 0;
	if ([self countryInContinent:maxCountry:initialContinent])
	{
		id enemyList = [self enemyNeighborsTo:maxCountry];

		if (enemyList)
		{
			if (numCountriesPerContinent[initialContinent] + [enemyList count] == 
				countriesPerContinent[initialContinent])
			{
				for (i=[enemyList count]-1;i>=0;i--)  
				{
					if ([self attackUntilLeft:3 from:maxCountry to:[enemyList objectAt:i] victory:&victory
						fromArmies:&fromArmies toArmies: &toArmies vanquished:&vanquished 
						weWin:&weWin])
					[self moveArmies:fromArmies-((round>25)?4:1) from:maxCountry to:minEnemy];
				}
			}
			[enemyList free];
	}
		
	}
	return 0; // added by Don Yacktman to supress warnings...
		
}

@end
