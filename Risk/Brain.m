//
// This file is a part of Risk by Mike Ferris.
//

#import "Risk.h"

RCSID ("$Id: Brain.m,v 1.1.1.1 1997/12/09 07:18:53 nygard Exp $");

#import "Brain.h"

#import "RiskMapView.h"
#import "Country.h"
#import "CountryShape.h"
#import "NewGameController.h"
#import "PreferenceController.h"
#import "RiskWorld.h"
#import "RiskGameManager.h"
#import "Version.h"

@implementation Brain
@synthesize gameManager;

+ (void) initialize
{
    NSUserDefaults *defaults;
    NSMutableDictionary *riskDefaults;

    if (self == [Brain class])
    {
        defaults = [NSUserDefaults standardUserDefaults];
        riskDefaults = [NSMutableDictionary dictionary];

        [riskDefaults setObject:@"NO"      forKey:DK_DMakeActive];
        [riskDefaults setObject:@"None"    forKey:DK_DefaultPlayer1Type];
        [riskDefaults setObject:@"None"    forKey:DK_DefaultPlayer2Type];
        [riskDefaults setObject:@"None"    forKey:DK_DefaultPlayer3Type];
        [riskDefaults setObject:@"None"    forKey:DK_DefaultPlayer4Type];
        [riskDefaults setObject:@"None"    forKey:DK_DefaultPlayer5Type];
        [riskDefaults setObject:@"None"    forKey:DK_DefaultPlayer6Type];
                                                                       
        [riskDefaults setObject:@"Dopey"   forKey:DK_DefaultPlayer1Name];
        [riskDefaults setObject:@"Sneezy"  forKey:DK_DefaultPlayer2Name];
        [riskDefaults setObject:@"Grumpy"  forKey:DK_DefaultPlayer3Name];
        [riskDefaults setObject:@"Doc"     forKey:DK_DefaultPlayer4Name];
        [riskDefaults setObject:@"Bashful" forKey:DK_DefaultPlayer5Name];
        [riskDefaults setObject:@"Sleepy"  forKey:DK_DefaultPlayer6Name];

        [riskDefaults setObject:@"NO"      forKey:DK_ShowPlayer1Console];
        [riskDefaults setObject:@"NO"      forKey:DK_ShowPlayer2Console];
        [riskDefaults setObject:@"NO"      forKey:DK_ShowPlayer3Console];
        [riskDefaults setObject:@"NO"      forKey:DK_ShowPlayer4Console];
        [riskDefaults setObject:@"NO"      forKey:DK_ShowPlayer5Console];
        [riskDefaults setObject:@"NO"      forKey:DK_ShowPlayer6Console];

        [defaults registerDefaults:riskDefaults];
    }
}

//----------------------------------------------------------------------

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSUserDefaults *defaults;
    RiskWorld *riskWorld;
    BOOL flag;

    defaults = [NSUserDefaults standardUserDefaults];

    riskWorld = [RiskWorld defaultRiskWorld];
    [gameManager setWorld:riskWorld];

    [self loadRiskPlayerBundles];

    flag = [defaults boolForKey:DK_DMakeActive];

    if (flag == YES)
    {
        [NSApp activateIgnoringOtherApps:YES];
    }
}

//----------------------------------------------------------------------

- (id)init
{
    if (self = [super init]) {
        riskPlayerBundles = [[NSMutableArray array] retain];
        gameManager = [[RiskGameManager alloc] init];
        preferenceController = nil;
    }

    return self;
}

//----------------------------------------------------------------------

- (void) dealloc
{
    SNRelease (gameManager);
    SNRelease (newGameController);
    SNRelease (riskPlayerBundles);
    SNRelease (preferenceController);

    [super dealloc];
}

//----------------------------------------------------------------------

- (IBAction) showNewGamePanel:(id)sender
{
    if (newGameController == nil)
        newGameController = [[NewGameController alloc] initWithBrain:self];

    [newGameController showNewGamePanel];
}

//----------------------------------------------------------------------

- (IBAction) showGameSetupPanel:(id)sender
{
    if (newGameController == nil)
        newGameController = [[NewGameController alloc] initWithBrain:self];

    [newGameController showGameSetupPanel];
}

//----------------------------------------------------------------------

- (IBAction) info:(id)sender
{
    NSString *nibFile;
    BOOL loaded;

    if (infoPanel == nil)
    {
        nibFile = @"InfoPanel.nib";
        loaded = [NSBundle loadNibNamed:nibFile owner:self];

        NSAssert1 (loaded == YES, @"Could not load %@.", nibFile);

        [versionTextField setStringValue:RISK_VERSION];
    }

    [infoPanel makeKeyAndOrderFront:self];
}

//----------------------------------------------------------------------

- (IBAction) showPreferencePanel:(id)sender
{
    if (preferenceController == nil)
    {
        preferenceController = [[PreferenceController alloc] init];
    }

    [preferenceController showPanel];
}

//----------------------------------------------------------------------

- (void) loadRiskPlayerBundles
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSMutableSet<NSString*> *loadedRiskPlayerNames = [NSMutableSet set];
    NSMutableSet<NSString*> *delayedRiskPlayerPaths = [NSMutableSet set];
    NSMutableSet<NSString*> *tempPlayerNames = [NSMutableSet set];
    NSBundle *playerBundle;
    BOOL keepTrying;
    NSMutableDictionary *loadedBundles = [NSMutableDictionary dictionary];

	NSURL *pluginURL = [mainBundle builtInPlugInsURL];
	NSDirectoryEnumerator<NSURL *> * URLEnum = [[NSFileManager defaultManager] enumeratorAtURL:pluginURL includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
		return false;
	}];

    //NSLog (@"resource paths: %@", resourcePaths);

    for (NSURL *subdirURL in URLEnum)
    {
		if ([[subdirURL pathExtension] caseInsensitiveCompare:@"riskplayer"] != NSOrderedSame) {
			continue;
		}
        NSString *str = [[subdirURL lastPathComponent] stringByDeletingPathExtension];

        // refuse to load if the name matches a module already loaded
        if ([loadedRiskPlayerNames containsObject:str] == NO)
        {
            // OK, all is well -- go load the little bugger
            //NSLog (@"Load risk player bundle %@", path);
            playerBundle = [NSBundle bundleWithURL:subdirURL];
            if ([playerBundle principalClass] == nil)
            {
                // Ugh, failed.  Put the class name in tempStorage in case
                // it can't be loaded because it's a subclass of another
                // CP who hasn't been loaded yet.
                [delayedRiskPlayerPaths addObject:[subdirURL path]];
            }
            else
            {
                // it loaded so add it to the list.
                [loadedBundles setObject:playerBundle forKey:str];
                //NSLog (@"str: %@, playerBundle: %@", str, playerBundle);
                //NSLog (@"priciple class is %@", [playerBundle principalClass]);
                [loadedRiskPlayerNames addObject:str];
            }
        }
    }

    // now loop and keep trying to load the ones in tempStorage.  Keep trying
    // as long as at least one of the failed ones succeeds each time through
    // the loop

    do
    {
        keepTrying = NO;
        for (NSString *path in delayedRiskPlayerPaths)
        {
            playerBundle = [NSBundle bundleWithPath:path];
            if ([playerBundle principalClass] != nil)
            {
                NSString *str = [[path lastPathComponent] stringByDeletingPathExtension];

                [loadedBundles setObject:playerBundle forKey:str];
                //NSLog (@"str: %@, playerBundle: %@", str, playerBundle);
                //NSLog (@"(delayed) priciple class is %@", [playerBundle principalClass]);
                keepTrying = YES;
                [tempPlayerNames addObject:path];
                [loadedRiskPlayerNames addObject:str];
            }
        }

        [delayedRiskPlayerPaths minusSet:tempPlayerNames];
        [tempPlayerNames removeAllObjects];
    }
    while (keepTrying == YES);

    // now cpNameStorage contains a list of all the menu strings.
    // we must add them to the menus in the panel.

    //NSLog (@"info: %@", [testBundle infoDictionary]);

    [riskPlayerBundles addObjectsFromArray:[loadedBundles allValues]];
}

//----------------------------------------------------------------------

- (NSArray *) riskPlayerBundles
{
    return riskPlayerBundles;
}

@end
