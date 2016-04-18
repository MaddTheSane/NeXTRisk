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
{
    NSArray *nibObjs;
}
@synthesize gameManager;

+ (void) initialize
{
    NSUserDefaults *defaults;
    NSMutableDictionary *riskDefaults;
    
    if (self == [Brain class])
    {
        defaults = [NSUserDefaults standardUserDefaults];
        riskDefaults = [[NSMutableDictionary alloc] init];
        
        riskDefaults[DK_DMakeActive] = @NO;
        riskDefaults[DK_DefaultPlayer1Type] = @"None";
        riskDefaults[DK_DefaultPlayer2Type] = @"None";
        riskDefaults[DK_DefaultPlayer3Type] = @"None";
        riskDefaults[DK_DefaultPlayer4Type] = @"None";
        riskDefaults[DK_DefaultPlayer5Type] = @"None";
        riskDefaults[DK_DefaultPlayer6Type] = @"None";
        
        riskDefaults[DK_DefaultPlayer1Name] = @"Dopey";
        riskDefaults[DK_DefaultPlayer2Name] = @"Sneezy";
        riskDefaults[DK_DefaultPlayer3Name] = @"Grumpy";
        riskDefaults[DK_DefaultPlayer4Name] = @"Doc";
        riskDefaults[DK_DefaultPlayer5Name] = @"Bashful";
        riskDefaults[DK_DefaultPlayer6Name] = @"Sleepy";
        
        riskDefaults[DK_ShowPlayer1Console] = @NO;
        riskDefaults[DK_ShowPlayer2Console] = @NO;
        riskDefaults[DK_ShowPlayer3Console] = @NO;
        riskDefaults[DK_ShowPlayer4Console] = @NO;
        riskDefaults[DK_ShowPlayer5Console] = @NO;
        riskDefaults[DK_ShowPlayer6Console] = @NO;
        
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

- (instancetype)init
{
    if (self = [super init]) {
        riskPlayerBundles = [NSMutableArray array];
        gameManager = [[RiskGameManager alloc] init];
        preferenceController = nil;
    }
    
    return self;
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
        nibFile = @"InfoPanel";
        NSArray *tmpArr;
        loaded = [[NSBundle mainBundle] loadNibNamed:nibFile owner:self topLevelObjects:&tmpArr];
        nibObjs = tmpArr;
        
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
    
    NSURL *pluginURL = mainBundle.builtInPlugInsURL;
    NSDirectoryEnumerator<NSURL *> * URLEnum = [[NSFileManager defaultManager] enumeratorAtURL:pluginURL includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
        return NO;
    }];
    
    //NSLog (@"resource paths: %@", resourcePaths);
    
    for (NSURL *subdirURL in URLEnum)
    {
        if ([subdirURL.pathExtension caseInsensitiveCompare:@"riskplayer"] != NSOrderedSame) {
            continue;
        }
        NSString *str = subdirURL.lastPathComponent.stringByDeletingPathExtension;
        
        // refuse to load if the name matches a module already loaded
        if ([loadedRiskPlayerNames containsObject:str] == NO)
        {
            // OK, all is well -- go load the little bugger
            //NSLog (@"Load risk player bundle %@", path);
            playerBundle = [NSBundle bundleWithURL:subdirURL];
            if (playerBundle.principalClass == nil)
            {
                // Ugh, failed.  Put the class name in tempStorage in case
                // it can't be loaded because it's a subclass of another
                // CP who hasn't been loaded yet.
                [delayedRiskPlayerPaths addObject:subdirURL.path];
            }
            else
            {
                // it loaded so add it to the list.
                loadedBundles[str] = playerBundle;
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
            if (playerBundle.principalClass != nil)
            {
                NSString *str = path.lastPathComponent.stringByDeletingPathExtension;
                
                loadedBundles[str] = playerBundle;
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
    
    [riskPlayerBundles addObjectsFromArray:loadedBundles.allValues];
}

//----------------------------------------------------------------------

- (NSArray *) riskPlayerBundles
{
    return riskPlayerBundles;
}

@end
