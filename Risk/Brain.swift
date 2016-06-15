//
//  Brain.swift
//  Risk
//
//  Created by C.W. Betts on 6/14/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Cocoa
import RiskKit.RiskGameManager

private var initOnce: dispatch_once_t = 0

@NSApplicationMain
class Brain: NSObject, NSApplicationDelegate {
    @IBOutlet weak var infoPanel: NSWindow!
    @IBOutlet weak var versionTextField: NSTextField!
    let gameManager = RiskGameManager()
    private(set) var riskPlayerBundles = [NSBundle]()
    private var nibObjs: NSArray?
    
    private var newGameController: NewGameController?
    private var preferenceController: PreferenceController?

    override class func initialize() {
        dispatch_once(&initOnce) { 
            let defaults = NSUserDefaults.standardUserDefaults()
            var riskDefaults = [String : AnyObject]()
            
            riskDefaults[DK_DMakeActive] = false;
            riskDefaults[DK_DefaultPlayer1Type] = "None";
            riskDefaults[DK_DefaultPlayer2Type] = "None";
            riskDefaults[DK_DefaultPlayer3Type] = "None";
            riskDefaults[DK_DefaultPlayer4Type] = "None";
            riskDefaults[DK_DefaultPlayer5Type] = "None";
            riskDefaults[DK_DefaultPlayer6Type] = "None";
            
            riskDefaults[DK_DefaultPlayer1Name] = "Dopey";
            riskDefaults[DK_DefaultPlayer2Name] = "Sneezy";
            riskDefaults[DK_DefaultPlayer3Name] = "Grumpy";
            riskDefaults[DK_DefaultPlayer4Name] = "Doc";
            riskDefaults[DK_DefaultPlayer5Name] = "Bashful";
            riskDefaults[DK_DefaultPlayer6Name] = "Sleepy";
            
            riskDefaults[DK_ShowPlayer1Console] = false;
            riskDefaults[DK_ShowPlayer2Console] = false;
            riskDefaults[DK_ShowPlayer3Console] = false;
            riskDefaults[DK_ShowPlayer4Console] = false;
            riskDefaults[DK_ShowPlayer5Console] = false;
            riskDefaults[DK_ShowPlayer6Console] = false;
            
            defaults.registerDefaults(riskDefaults)
        }
    }
 
    func applicationDidFinishLaunching(notification: NSNotification) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let riskWorld = RiskWorld.defaultRiskWorld()
        gameManager.world = riskWorld
        
        loadRiskPlayerBundles();
        
        let flag = defaults.boolForKey(DK_DMakeActive)
        
        if flag == true {
            NSApp.activateIgnoringOtherApps(true)
        }
    }
    
    func loadRiskPlayerBundles() {
        let mainBundle = NSBundle.mainBundle()
        var loadedRiskPlayerNames = Set<String>()
        var delayedRiskPlayerPaths = Set<String>()
        var playerBundle: NSBundle?
        var keepTrying = false
        var loadedBundles = [String: NSBundle]()
        
        let pluginURL = mainBundle.builtInPlugInsURL!
        let URLEnum = NSFileManager.defaultManager().enumeratorAtURL(pluginURL, includingPropertiesForKeys: nil, options: [.SkipsPackageDescendants, .SkipsHiddenFiles]) { (url, error) -> Bool in
            return false
        }!
        
        //NSLog (@"resource paths: %@", resourcePaths);
        
        for subdirURL1 in URLEnum {
            let subdirURL = subdirURL1 as! NSURL
            if let pathExt = subdirURL.pathExtension where pathExt.caseInsensitiveCompare("riskplayer") != .OrderedSame {
                continue;
            }
            let str = (subdirURL.lastPathComponent! as NSString).stringByDeletingPathExtension;
            
            // refuse to load if the name matches a module already loaded
            if !loadedRiskPlayerNames.contains(str) {
                // OK, all is well -- go load the little bugger
                //NSLog (@"Load risk player bundle %@", path);
                playerBundle = NSBundle(URL: subdirURL)
                if playerBundle?.principalClass == nil {
                    // Ugh, failed.  Put the class name in tempStorage in case
                    // it can't be loaded because it's a subclass of another
                    // CP who hasn't been loaded yet.
                    delayedRiskPlayerPaths.insert(subdirURL.path!)
                } else {
                    // it loaded so add it to the list.
                    loadedBundles[str] = playerBundle;
                    //NSLog (@"str: %@, playerBundle: %@", str, playerBundle);
                    //NSLog (@"priciple class is %@", [playerBundle principalClass]);
                    loadedRiskPlayerNames.insert(str)
                }
            }
        }
        
        // now loop and keep trying to load the ones in tempStorage.  Keep trying
        // as long as at least one of the failed ones succeeds each time through
        // the loop
        
        repeat {
			var tempPlayerNames = Set<String>()
            keepTrying = false;
            for path in delayedRiskPlayerPaths {
                playerBundle = NSBundle(path:path)
                if playerBundle?.principalClass != nil {
                    let str = ((path as NSString).lastPathComponent as NSString).stringByDeletingPathExtension;
                    
                    loadedBundles[str] = playerBundle;
                    //NSLog (@"str: %@, playerBundle: %@", str, playerBundle);
                    //NSLog (@"(delayed) priciple class is %@", [playerBundle principalClass]);
                    keepTrying = true;
					tempPlayerNames.insert(path)
					loadedRiskPlayerNames.insert(str)
                }
            }
			
			delayedRiskPlayerPaths.subtractInPlace(tempPlayerNames)
        } while (keepTrying == true);
        
        // now cpNameStorage contains a list of all the menu strings.
        // we must add them to the menus in the panel.
        
        //NSLog (@"info: %@", [testBundle infoDictionary]);
		
		riskPlayerBundles.appendContentsOf(loadedBundles.values)
    }
 
    @IBAction func showNewGamePanel(sender: AnyObject?) {
        if newGameController == nil {
            newGameController = NewGameController(brain:self)
        }
        
        newGameController!.showNewGamePanel()
    }
 
    @IBAction func showGameSetupPanel(sender: AnyObject?) {
        if newGameController == nil {
            newGameController = NewGameController(brain: self)
        }
        
        newGameController!.showGameSetupPanel()
    }

    @IBAction func info(sender: AnyObject?) {
        if infoPanel == nil {
            let nibFile = "InfoPanel";
            let loaded = NSBundle.mainBundle().loadNibNamed(nibFile, owner: self, topLevelObjects: &nibObjs)
            
            assert(loaded == true, "Could not load \(nibFile).");
            
            versionTextField.stringValue = RISK_VERSION_C
        }
        
        infoPanel.makeKeyAndOrderFront(self)
    }

    @IBAction func showPreferencePanel(sender: AnyObject?) {
        if preferenceController == nil {
            preferenceController = PreferenceController();
        }
        
        preferenceController!.showPanel()
    }
}
