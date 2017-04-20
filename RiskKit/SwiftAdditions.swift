//
//  SwiftAdditions.swift
//  Risk
//
//  Created by C.W. Betts on 4/18/17.
//  Copyright © 2017 C.W. Betts. All rights reserved.
//

import Foundation

extension InitialCountryDistribution: CustomStringConvertible {
    public init(string: String) {
        self = __initialCountryDistributionFromString(string)
    }
    
	public var description: String {
		return __NSStringFromInitialCountryDistribution(self)
	}
}

extension InitialArmyPlacement: CustomStringConvertible {
	public init(string: String) {
		self = __initialArmyPlacementFromString(string)
	}
	
	public var description: String {
		return __NSStringFromInitialArmyPlacement(self)
	}
}

extension CardSetRedemption: CustomStringConvertible {
	public init(string: String) {
		self = __cardSetRedemptionFromString(string)
	}
	
	public var description: String {
		return __NSStringFromCardSetRedemption(self)
	}
}

extension FortifyRule: CustomStringConvertible {
	public init(string: String) {
		self = __fortifyRuleFromString(string)
	}
	
	public var description: String {
		return __NSStringFromFortifyRule(self)
	}
}

extension RiskCardType: CustomStringConvertible {
	public var description: String {
		return __NSStringFromRiskCardType(self)
	}
}

extension GameState: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		return __gameStateInfo(self)
	}
	
	public var debugDescription: String {
		return __NSStringFromGameState(self)
	}
}
