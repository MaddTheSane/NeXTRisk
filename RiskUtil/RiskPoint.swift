//
//  RiskPoint.swift
//  Risk
//
//  Created by C.W. Betts on 6/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Foundation

private let RiskPoint_VERSION = 1
private let kRiskPoint = "Point"

/// A RiskPoint can be encoded on a stream and stored in arrays.
@objc(RiskPoint) final class RiskPoint: NSObject, NSSecureCoding {
	@objc let point: NSPoint
	private static var __doSomethingOnce: () = {
		RiskPoint.setVersion(RiskPoint_VERSION)
	}()
	
	//----------------------------------------------------------------------
	
	@objc class func setUpVersions() {
		_=RiskPoint.__doSomethingOnce
	}
	
	//----------------------------------------------------------------------
	
	@objc init(point: NSPoint) {
		self.point = point
		super.init()
	}
	
	//----------------------------------------------------------------------
	
	override convenience init() {
		self.init(point: .zero)
	}
	
	//----------------------------------------------------------------------
	
	static var supportsSecureCoding: Bool {
		return true
	}
	
	//----------------------------------------------------------------------
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(point, forKey: kRiskPoint)
	}
	
	//----------------------------------------------------------------------
	
	convenience init?(coder aDecoder: NSCoder) {
		let bPoint: NSPoint
		if aDecoder.allowsKeyedCoding {
			bPoint = aDecoder.decodePoint(forKey: kRiskPoint)
		} else {
			bPoint = aDecoder.decodePoint()
		}
		self.init(point: bPoint)
	}
	
	//----------------------------------------------------------------------
	
	override var description: String {
		return "<RiskPoint: \(point.x),\(point.y)>"
	}
	
	//----------------------------------------------------------------------
	
}
