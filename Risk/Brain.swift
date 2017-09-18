//
//  Brain.swift
//  Risk
//
//  Created by C.W. Betts on 6/14/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Cocoa
import RiskKit.RiskGameManager

@NSApplicationMain
class Brain: NSObject, NSApplicationDelegate {
    private static var __once: () = { 
            let defaults = UserDefaults.standard
            var riskDefaults = [String : Any]()
            
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
            
            defaults.register(defaults: riskDefaults)
        }()
    @IBOutlet weak var infoPanel: NSWindow!
    @IBOutlet weak var versionTextField: NSTextField!
    @objc let gameManager = RiskGameManager()
    @objc private(set) var riskPlayerBundles = [Bundle]()
    private var nibObjs: NSArray?
    
    private var newGameController: NewGameController?
    private var preferenceController: PreferenceController?

	override init() {
		_ = Brain.__once
		// hack to get around the initialize() problems:
		UserPath.setUpVersions()
		RiskPoint.setUpVersions()
		super.init()
	}
 
    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaults = UserDefaults.standard
        
        let riskWorld = RiskWorld.default()
        gameManager.world = riskWorld
        
        loadRiskPlayerBundles();
        
        let flag = defaults.bool(forKey: DK_DMakeActive)
        
        if flag == true {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func loadRiskPlayerBundles() {
        let mainBundle = Bundle.main
        var loadedRiskPlayerNames = Set<String>()
        var delayedRiskPlayerPaths = Set<String>()
        var playerBundle: Bundle?
        var keepTrying = false
        var loadedBundles = [String: Bundle]()
        
        let pluginURL = mainBundle.builtInPlugInsURL!
        let URLEnum = FileManager.default.enumerator(at: pluginURL, includingPropertiesForKeys: nil, options: [.skipsPackageDescendants, .skipsHiddenFiles]) { (url, error) -> Bool in
            return false
        }!
        
        //NSLog (@"resource paths: %@", resourcePaths);
        
        for subdirURL1 in URLEnum {
            let subdirURL = subdirURL1 as! URL
			let pathExt = subdirURL.pathExtension
            guard pathExt.caseInsensitiveCompare("riskplayer") == .orderedSame else {
                continue;
            }
            let str = (subdirURL.lastPathComponent as NSString).deletingPathExtension;
            
            // refuse to load if the name matches a module already loaded
            if !loadedRiskPlayerNames.contains(str) {
                // OK, all is well -- go load the little bugger
                //NSLog (@"Load risk player bundle %@", path);
                playerBundle = Bundle(url: subdirURL)
                if playerBundle?.principalClass == nil {
                    // Ugh, failed.  Put the class name in tempStorage in case
                    // it can't be loaded because it's a subclass of another
                    // CP who hasn't been loaded yet.
                    delayedRiskPlayerPaths.insert(subdirURL.path)
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
                playerBundle = Bundle(path:path)
                if playerBundle?.principalClass != nil {
                    let str = ((path as NSString).lastPathComponent as NSString).deletingPathExtension;
                    
                    loadedBundles[str] = playerBundle;
                    //NSLog (@"str: %@, playerBundle: %@", str, playerBundle);
                    //NSLog (@"(delayed) priciple class is %@", [playerBundle principalClass]);
                    keepTrying = true;
					tempPlayerNames.insert(path)
					loadedRiskPlayerNames.insert(str)
                }
            }
			
			delayedRiskPlayerPaths.subtract(tempPlayerNames)
        } while (keepTrying == true);
        
        // now cpNameStorage contains a list of all the menu strings.
        // we must add them to the menus in the panel.
        
        //NSLog (@"info: %@", [testBundle infoDictionary]);
		
		riskPlayerBundles.append(contentsOf: loadedBundles.values)
    }
 
    @IBAction func showNewGamePanel(_ sender: AnyObject?) {
        if newGameController == nil {
            newGameController = NewGameController(brain:self)
        }
        
        newGameController!.showNewGamePanel()
    }
 
    @IBAction func showGameSetupPanel(_ sender: AnyObject?) {
        if newGameController == nil {
            newGameController = NewGameController(brain: self)
        }
        
        newGameController!.showGameSetupPanel()
    }

    @IBAction func info(_ sender: AnyObject?) {
        if infoPanel == nil {
            let nibFile = "InfoPanel";
            let loaded = Bundle.main.loadNibNamed(NSNib.Name(rawValue: nibFile), owner: self, topLevelObjects: &nibObjs)
            
            assert(loaded == true, "Could not load \(nibFile).");
            
            versionTextField.stringValue = RISK_VERSION_C
        }
        
        infoPanel.makeKeyAndOrderFront(self)
    }

    @IBAction func showPreferencePanel(_ sender: AnyObject?) {
        if preferenceController == nil {
            preferenceController = PreferenceController();
        }
        
        preferenceController!.showPanel()
    }
}
