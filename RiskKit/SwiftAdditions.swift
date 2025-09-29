//
//  SwiftAdditions.swift
//  Risk
//
//  Created by C.W. Betts on 4/18/17.
//  Copyright © 2017 C.W. Betts. All rights reserved.
//

import Foundation

extension RKInitialCountryDistribution: LosslessStringConvertible {
	@available(*, deprecated, renamed: "init(_:)")
	@inlinable public init(string: String) {
		self = Self(string)
	}
}

extension RKInitialArmyPlacement: LosslessStringConvertible {
	@available(*, deprecated, renamed: "init(_:)")
	@inlinable public init(string: String) {
		self = Self(string)
	}
}

extension RKCardSetRedemption: LosslessStringConvertible {
	@available(*, deprecated, renamed: "init(_:)")
	@inlinable public init(string: String) {
		self = Self(string)
	}
}

extension RKFortifyRule: LosslessStringConvertible {
	@available(*, deprecated, renamed: "init(_:)")
	@inlinable public init(string: String) {
		self = Self(string)
	}
}

extension RKCardType: CustomStringConvertible {
}

extension RKGameState: CustomStringConvertible, CustomDebugStringConvertible {
}

extension RiskPlayer {
	/// Appends a formatted string to the console window, if it is visible.
	/// Subclasses can use this to show debugging information.
	public func logMessage(_ format: String, _ args: CVarArg...) {
		withVaList(args) { (vaList) -> Void in
			logMessage(format, format: vaList)
		}
	}
}

extension SNRandom {
	public func randomNumberBetween(_ minimum: Int32, _ maximum: Int32) -> Int32 {
		return Int32(randomNumberBetween(Int(minimum), Int(maximum)))
	}
	
	public func randomNumber(withMaximum maximum: Int32) -> Int32 {
		return Int32(randomNumber(withMaximum: Int(maximum)))
	}
}
