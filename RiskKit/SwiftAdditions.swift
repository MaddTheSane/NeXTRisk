//
//  SwiftAdditions.swift
//  Risk
//
//  Created by C.W. Betts on 4/18/17.
//  Copyright © 2017 C.W. Betts. All rights reserved.
//

import Foundation

extension RKInitialCountryDistribution: CustomStringConvertible {
    @inlinable public init(string: String) {
        self = __RKInitialCountryDistributionFromString(string)
    }
    
	@inlinable public var description: String {
		return __NSStringFromInitialCountryDistribution(self)
	}
}

extension RKInitialArmyPlacement: CustomStringConvertible {
	@inlinable public init(string: String) {
		self = __RKInitialArmyPlacementFromString(string)
	}
	
	@inlinable public var description: String {
		return __NSStringFromInitialArmyPlacement(self)
	}
}

extension RKCardSetRedemption: CustomStringConvertible {
	@inlinable public init(string: String) {
		self = __RKCardSetRedemptionFromString(string)
	}
	
	@inlinable public var description: String {
		return __NSStringFromCardSetRedemption(self)
	}
}

extension RKFortifyRule: CustomStringConvertible {
	@inlinable public init(string: String) {
		self = __RKFortifyRuleFromString(string)
	}
	
	@inlinable public var description: String {
		return __NSStringFromFortifyRule(self)
	}
}

extension RKCardType: CustomStringConvertible {
	@inlinable public var description: String {
		return __NSStringFromRiskCardType(self)
	}
}

extension RKGameState: CustomStringConvertible, CustomDebugStringConvertible {
	@inlinable public var description: String {
		return __RKGameStateInfo(self)
	}
	
	@inlinable public var debugDescription: String {
		return __NSStringFromGameState(self)
	}
}

extension RiskPlayer {
	/// Appends a formatted string to the console window, if it is visible.
	/// Subclasses can use this to show debugging information.
	open func logMessage(_ format: String, _ args: CVarArg...) {
		withVaList(args) { (vaList) -> Void in
			logMessage(format, format: vaList)
		}
	}
}

extension SNRandom {
	open func randomNumberBetween(_ minimum: Int32, _ maximum: Int32) -> Int32 {
		return Int32(randomNumberBetween(Int(minimum), Int(maximum)))
	}
	
	open func randomNumber(withMaximum maximum: Int32) -> Int32 {
		return Int32(randomNumber(withMaximum: Int(maximum)))
	}
}
