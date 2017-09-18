#import "Haudruf.h"
#import <AppKit/AppKit.h>
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
	 */
	[haudrufPanel orderFront:self];
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
	[self setNotes:@"sent by -yourChooseCountry.  "
	 "yourChooseCountry chose a country at random."];
	[gameManager player:self choseCountry:country];
	[self turnDone];
}

- (void)placeInitialArmies:(int)numArmies
{	
	if (![self calcNumCountriesPerContinent])
	{
		NSRunAlertPanel(@"BUG", @"", NULL,NULL, NULL);
		return;
	}
	round = 0;
	if(numCountriesPerContinent[initialContinent = RiskContinentAustralia] >= 2)
		[gameManager player:self placesArmies:numArmies inCountry:[self bestCountryFor:RiskContinentAustralia]];
	else if(numCountriesPerContinent[initialContinent = RiskContinentSouthAmerica] >= 2)
		[gameManager player:self placesArmies:numArmies inCountry:[self bestCountryFor:RiskContinentSouthAmerica]];
	else if(numCountriesPerContinent[initialContinent = RiskContinentNorthAmerica] >= 4)
		[gameManager player:self placesArmies:numArmies inCountry:[self bestCountryFor:RiskContinentNorthAmerica]];
	else if(numCountriesPerContinent[initialContinent = RiskContinentAfrica] >= 3)
		[gameManager player:self placesArmies:numArmies inCountry:[self bestCountryFor:RiskContinentAfrica]];
	else if(numCountriesPerContinent[initialContinent = RiskContinentSouthAmerica] >= 1)
		[gameManager player:self placesArmies:numArmies inCountry:[self bestCountryFor:RiskContinentSouthAmerica]];
	else if(numCountriesPerContinent[initialContinent = RiskContinentAustralia] >= 1)
		[gameManager player:self placesArmies:numArmies inCountry:[self bestCountryFor:RiskContinentAustralia]];
	else if(numCountriesPerContinent[initialContinent = RiskContinentNorthAmerica] >= 2)
		[gameManager player:self placesArmies:numArmies inCountry:[self bestCountryFor:RiskContinentNorthAmerica]];
	else if(numCountriesPerContinent[initialContinent = RiskContinentAfrica] >= 2)
		[gameManager player:self placesArmies:numArmies inCountry:[self bestCountryFor:RiskContinentAfrica]];
	else if(numCountriesPerContinent[initialContinent = RiskContinentNorthAmerica] >= 1)
		[gameManager player:self placesArmies:numArmies inCountry:[self bestCountryFor:RiskContinentNorthAmerica]];
	else
		[self placeArmies:numArmies inCountry:[self bestCountryFor:SCHEISSE]];
	[self turnDone];
}

#if 0
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
			numArmiesLeft -= [self defendContinent:i armies:numArmiesLeft];
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

- (void)playerNumber:(Player)number attackedCountry:(Country *)attackedCountry;
{
	// do nothing.  these methods are for advanced players only.
	// but we do set the notes and pause if we should.
	[self setNotes:@"-youWereAttacked: by: was called."];
	[self clearArgForms];
	[functionCalledForm setStringValue:@""];
	[returnValueForm setStringValue:@""];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
}

- (void)playerNumber:(Player)number capturedCountry:(Country *)capturedCountry;
{
	// do nothing.  these methods are for advanced players only.
	// but we do set the notes and pause if we should.
	[self setNotes:@"-youLostCountry: to: was called."];
	[self clearArgForms];
	[functionCalledForm setStringValue:@""];
	[returnValueForm setStringValue:@""];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
}

// *****************country utilities*********************

- (BOOL)occupyCountry:(Country *)country
{
	BOOL retVal;
	
	//[super occu]
	//[gameManager occ]
	retVal = [super occupyCountry:country];
	[self clearArgForms];
	[[functionCalledForm cellAtIndex:0] setStringValue:@"(BOOL)occupyCountry:"];
	[[args1Form cellAtIndex:0] setTitle:@"country"];
	if (country == nil)  {
		[[args1Form cellAtIndex:0] setStringValue:@"(nil)"];
	}  else  {
		[[args1Form cellAtIndex:0] setStringValue:[country countryName]];
	}
	if (retVal)  {
		[[returnValueForm cellAtIndex:0] setStringValue:@"YES"];
	}  else  {
		[[returnValueForm cellAtIndex:0] setStringValue:@"NO"];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************card utilities*********************

- (int)playCards:(CardSet *)cardList
{
	int retVal;
	
	[gameManager turnInCardSet:cardList forPlayerNumber:self.playerNumber];
	[self clearArgForms];
	[(NSFormCell*)[functionCalledForm cellAtIndex:0] setStringValue:@"(int)playCards:"];
	[(NSFormCell*)[args1Form cellAtIndex:0] setTitle:@"cardList"];
	if (cardList == nil)  {
		[(NSFormCell*)[args1Form cellAtIndex:0] setStringValue:@"nil"];
	}  else  {
		[(NSFormCell*)[args1Form cellAtIndex:0] setStringValue:@"list of cards"];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
	
	return retVal;
}

// *****************place army utilities*********************

- (BOOL)placeArmies:(int)numArmies inCountry:(Country *)country
{
	BOOL retVal;
	
	retVal = [gameManager player:self placesArmies:numArmies inCountry:country];
	[self clearArgForms];
	[(NSFormCell*)[functionCalledForm cellAtIndex:0] setStringValue:@"(BOOL)placeArmies: inCountry:"];
	[(NSFormCell*)[args1Form cellAtIndex:0] setTitle:@"numArmies"];
	[(NSFormCell*)[args1Form cellAtIndex:0] setIntValue:0];
	[(NSFormCell*)[args1Form cellAtIndex:1] setTitle:@"country"];
	if (country == nil)  {
		[(NSFormCell*)[args1Form cellAtIndex:1] setStringValue:@"nil"];
	}  else  {
		[(NSFormCell*)[args1Form cellAtIndex:1] setStringValue:[country countryName]];
	}
	if (retVal)  {
		[(NSFormCell*)[returnValueForm cellAtIndex:0] setStringValue:@"YES"];
	}  else  {
		[(NSFormCell*)[returnValueForm cellAtIndex:0] setStringValue:@"NO"];
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

- (void)moveAttackingArmies:(int)numArmies between:(Country *)fromCountry :(Country *)toCountry
{
	//BOOL retVal;
	
	[super moveAttackingArmies:numArmies between:fromCountry :toCountry];
	[self clearArgForms];
	[[functionCalledForm cellAtIndex:0] setStringValue:@"(BOOL)moveArmies: from: to:"];
	[[args1Form cellAtIndex:0] setTitle:@"numArmies"];
	[[args1Form cellAtIndex:0] setIntValue:numArmies];
	[[args1Form cellAtIndex:1] setTitle:@"fromCountry"];
	if (fromCountry == nil)  {
		[[args1Form cellAtIndex:1] setStringValue:@"(nil)"];
	}  else  {
		[[args1Form cellAtIndex:1] setStringValue:fromCountry.countryName];
	}
	[[args1Form cellAtIndex:2] setTitle:@"toCountry"];
	if (toCountry == nil)  {
		[[args1Form cellAtIndex:2] setStringValue:@"(nil)"];
	}  else  {
		[[args1Form cellAtIndex:2] setStringValue:toCountry.countryName];
	}
	[haudrufPanel orderFront:self];
	if ([pauseContinueButton state] == 1)  {
		[self waitForContinue];
	}
}

// *****************special haudruf methods*********************

- (void)waitForContinue
{
	NSInteger retVal;
	
	NSBeep();
	if (![haudrufPanel isVisible])
		[haudrufPanel orderFront:self];
	[pauseContinueButton setEnabled:NO];
	retVal = [NSApp runModalForWindow:haudrufPanel];
}

- (IBAction)continueAction:sender
{
	[NSApp stopModal];
	[pauseContinueButton setEnabled:YES];
}

- (IBAction)checkAction:sender
{
	if ([sender state] == 1)  {
		[continueButton setEnabled:YES];
	}  else  {
		[continueButton setEnabled:NO];
	}
}

- (void)clearArgForms
{
	[(NSFormCell*)[args1Form cellAtIndex:0] setTitle:@"arg1:"];
	[(NSFormCell*)[args1Form cellAtIndex:1] setTitle:@"arg2:"];
	[(NSFormCell*)[args1Form cellAtIndex:2] setTitle:@"arg3:"];
	[(NSFormCell*)[args1Form cellAtIndex:3] setTitle:@"arg4:"];
	[(NSFormCell*)[args2Form cellAtIndex:0] setTitle:@"arg5:"];
	[(NSFormCell*)[args2Form cellAtIndex:1] setTitle:@"arg6:"];
	[(NSFormCell*)[args2Form cellAtIndex:2] setTitle:@"arg7:"];
	[(NSFormCell*)[args2Form cellAtIndex:3] setTitle:@"arg8:"];
	[(NSFormCell*)[args1Form cellAtIndex:0] setStringValue:@""];
	[(NSFormCell*)[args1Form cellAtIndex:1] setStringValue:@""];
	[(NSFormCell*)[args1Form cellAtIndex:2] setStringValue:@""];
	[(NSFormCell*)[args1Form cellAtIndex:3] setStringValue:@""];
	[(NSFormCell*)[args2Form cellAtIndex:0] setStringValue:@""];
	[(NSFormCell*)[args2Form cellAtIndex:1] setStringValue:@""];
	[(NSFormCell*)[args2Form cellAtIndex:2] setStringValue:@""];
	[(NSFormCell*)[args2Form cellAtIndex:3] setStringValue:@""];
}

- (void)setNotes:(NSString *)noteText
{
	[[[notesScrollText documentView] textStorage] setAttributedString: [[NSAttributedString alloc] initWithString:noteText]];
}

- (BOOL)calcNumCountriesPerContinent
{
	NSInteger i,j,k, numContCountries, numMyCountries, tmp;
	NSArray *countryList;
	NSSet<Country*> *mycountries = [gameManager.world countriesForPlayer:playerNumber];
	
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
				if ([[mycountries objectAtIndex:j] idNum] == [[countryList objectAtIndex:k] idNum])
				{
					tmp = numCountriesPerContinent[i]++;
					countriesInContinent[i][tmp] = [[countryList objectAtIndex:k] idNum];
				}
			}
		}
		if(numCountriesPerContinent[i] == countriesPerContinent[i])
		{
			gotContinent[i]= YES;
			numGotContinents++;
		}
	}
	return YES;
}
#endif

- (Country*)bestCountryFor:(RiskContinent)continent
{
	id countryList = gameManager.world.continents ;
	Country *retCountry;
	NSInteger i;
	
	for (i=0; i<[countryList count]; i++)
	{
		if ([[[countryList objectAtIndex:i] countryName] isEqualToString: countriesInContinent[continent][0]])
		{
			retCountry = [countryList objectAtIndex:i];
			return retCountry;
		}
	}
	return nil;
}

#if 0
- (BOOL)country:(Country *)country isInContinent:(RiskContinent)continent
{
	id contlist = [gameManager.world countriesInContinent:continent];
	int i, num;
	
	num = [contlist count];
	for (i=0; i<num; i++)
	{
		if([[contlist objectAtIndex:i] idNum] == [country idNum])
		{
			return YES;
		}
	}
	return NO;
}

- (int)turnInCards
{
	CardSet *cardSet;
	int temp, numArmies = 0;
	
	cardSet = [self bestSet];
	while (cardSet != nil)
	{
		temp = [self playCards:cardSet];
		if (temp == -1)
		{
			NSRunAlertPanel(@"Debug", @"bestSet returned an invalid cardset",
							@"OK", NULL, NULL);
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

- (int)defendContinent:(RiskContinent)continent armies:(RiskArmyCount)armiesLeft
{
	//	id maxCountry;
	fprintf(stderr, "defend:%d with:%d\n", continent, armiesLeft);
	//	return maxCountry;
	//	maxCountry = [self getMaxArmyCountry];
	
	if (continent == RiskContinentAustralia)
	{
		fprintf(stderr, "defend Australia:%d with:%d\n", continent, armiesLeft);
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:@"Indonesia"]];
		return MIN(armiesLeft,5);
	}
	else if (continent == RiskContinentSouthAmerica)
	{
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:@"Brazil"]];
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:@"Venezuela"]];
		return MIN(armiesLeft,5);
	}
	else if (continent == RiskContinentNorthAmerica)
	{
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:@"Alaska"]];
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:@"Greenland"]];
		[self placeArmies:MIN(armiesLeft,5) inCountry:[self getCountryNamed:@"Central America"]];
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

- (Country *)findBestVictimFor:(Country *)country
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
				minEnemy = [enemyList objectAtIndex:i];
				min = [minEnemy armies];
			}
		}
		if ([self attackUntilLeft:3 from:country to:minEnemy victory:&victory
					   fromArmies:&fromArmies toArmies: &toArmies vanquished:&vanquished
							weWin:&weWin])
			[self moveArmies:fromArmies-((round>25)?4:1) from:country to:minEnemy];
		if ((round > 20) && (turn<10))
		{
			if (enemyList=[self neighborsTo:minEnemy])
			{
				return minEnemy;
			}
		}
	}
	return nil;
}

- (void)fortifyPosition
{
	id tmp, maxCountry;
	
	if ([tmp=[self enemyNeighborsTo:maxCountry=[self getMaxArmyCountry]] count])
	{
		return;
	}
	tmp = [self neighborsTo:maxCountry];
	//	fprintf(stderr, "armies:%d from:%s to:%s",
	//		[maxCountry armies], [maxCountry name],[[tmp objectAt:1] name]);
	[self moveArmies:[maxCountry armies]-1 from:maxCountry to:[tmp objectAt:[rng randMax:[tmp count]-1]]];
}

- (Country *)getMaxArmyWithEnemyCountry
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
	return maxCountry;
}

- (Country *)getMaxArmyCountry
{
	NSArray *armieCountries;
	int cnt, i, max=0;
	Country *maxCountry=nil;
	
	if (!(armieCountries=[self myCountriesWithAvailableArmies]))
		armieCountries=[self countryList];
	cnt = [armieCountries count];
	for (i=0; i<cnt; i++)
	{
		if([[armieCountries objectAtIndex:i] armies] > max)
		{
			max = [[armieCountries objectAtIndex:i] armies];
			maxCountry = [armieCountries objectAtIndex:i];
		}
	}
	return maxCountry;
}

- (Country *)getCountryNamed:(char*)name
{
	NSArray *countryList = [self myCountries];
	int i,cnt = [countryList count];
	
	for (i=0; i<cnt; i++)
	{
		if (!strcmp(name, [(Country *)[countryList objectAtIndex:i] name]))
		{
			//			fprintf(stderr, "Got:%s Wanted:%s\n",[[countryList objectAt:i] name], name);
			return [countryList objectAtIndex:i];
		}
	}
	return nil;
}

- (int) checkInitialContinent:(RiskContinent) numArmies
{
	int i, fromArmies, toArmies;
	//	int i, min=10000, fromArmies, toArmies;
	BOOL victory, weWin, vanquished;
	id minEnemy=nil;
	
	Country *maxCountry = [self getMaxArmyCountry];
	
	if (gotContinent[initialContinent])
		return 0;
	if (numCountriesPerContinent[initialContinent] == 0)
		return 0;
	if ([self countryInContinent:maxCountry:initialContinent])
	{
		NSSet *enemyList = maxCountry.enemyNeighborCountries;
		
		if (enemyList)
		{
			if (numCountriesPerContinent[initialContinent] + [enemyList count] ==
				countriesPerContinent[initialContinent])
			{
				for (Country *enemyCountry in enemyList)
				{
					if ([self attackUntilLeft:3 from:maxCountry to:enemyCountry victory:&victory
								   fromArmies:&fromArmies toArmies: &toArmies vanquished:&vanquished
										weWin:&weWin])
						[self moveArmies:fromArmies-((round>25)?4:1) from:maxCountry to:minEnemy];
				}
			}
		}
		
	}
	return 0; // added by Don Yacktman to supress warnings...
}
#endif

@end
