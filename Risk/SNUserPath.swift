//
//  SNUserPath.swift
//  Risk
//
//  Created by C.W. Betts on 6/15/16.
//  Copyright © 2016 C.W. Betts. All rights reserved.
//

import Cocoa

private let SNUserPath_VERSION = 1
private let SNUserPathOperation_VERSION = 1

/// An `SNUserPath` provides an interface for creating user paths and
/// using them for drawing or hit detection.  The bounding box
/// calculations are incomplete, but work with straight lines.
///
/// The `MiscKit` provides a more complete implementation.  Under Rhapsody
/// this will probably move towards using the `NSBezierPath` path.
///
/// Note that this means curved paths could be easily supported to
/// provide better looking maps, but RiskUtil.app would need to be
/// able to support them.
///
/// Superceded by `NSBezierPath`!
@objc(SNUserPath) final class UserPath: NSObject, NSCoding {
	private static var doSomethingOnce: () -> Void = {
		UserPath.setVersion(SNUserPath_VERSION)
		Operation.setVersion(SNUserPathOperation_VERSION)
		
		return {}
	}()
	
	class func setUpVersions() {
		_=UserPath.doSomethingOnce
	}
	
	/// An `SNUserPathOperation` represents an user path operator and its
	/// operands so that is can be stored in an array.
	///
	/// Please migrate over to `NSBezierPath`s instead!
	@objc(SNUserPathOperation) private final class Operation: NSObject, NSCoding {
		let op: DPSUserPathOp
		
		let point1: NSPoint
		let point2: NSPoint
		let point3: NSPoint
		
		//These aren't CGFloat to make sure decodeValue does not mangle the double
		let radius: Float
		let angle1: Float
		let angle2: Float
		
		@objc func encode(with aCoder: NSCoder) {
			fatalError("We should not be calling this!")
		}

		@objc init?(coder aDecoder: NSCoder) {
			op = aDecoder.decodeUserPathOpWithoutKey()
			point1 = aDecoder.decodePoint()
			point2 = aDecoder.decodePoint()
			point3 = aDecoder.decodePoint()
			radius = aDecoder.decodeFloatWithoutKey()
			angle1 = aDecoder.decodeFloatWithoutKey()
			angle2 = aDecoder.decodeFloatWithoutKey()
			super.init()
		}
		
		func applyToBezierPath(_ bPath: NSBezierPath) {
			switch op {
			case .dps_arc:
				bPath.appendArc(withCenter: point1, radius: CGFloat(radius), startAngle: CGFloat(angle1), endAngle: CGFloat(angle2), clockwise: true)
				
			case .dps_arcn:
				bPath.appendArc(withCenter: point1, radius: CGFloat(radius), startAngle: CGFloat(angle1), endAngle: CGFloat(angle2), clockwise: false)
				
			case .dps_arct:
				bPath.appendArc(from: point1, to: point2, radius: CGFloat(radius))
				
			case .dps_closepath:
				bPath.close()
				
			case .dps_curveto:
				bPath.curve(to: point1, controlPoint1: point2, controlPoint2: point3)
				
			case .dps_lineto:
				bPath.line(to: point1)
				
			case .dps_moveto:
				bPath.move(to: point1)
				
			case .dps_ucache:
				//Do nothing
				break;
				
			case .dps_rcurveto:
				bPath.relativeCurve(to: point1, controlPoint1: point2, controlPoint2: point3)
				
			case .dps_rlineto:
				bPath.relativeLine(to: point1)
				
			case .dps_rmoveto:
				bPath.relativeMove(to: point1)
				
			case .dps_setbbox:
				//[bPath set]
				break;
				
			//default:
			//	NSLog("Unknown op: %i", op.rawValue);
			}
		}
		
		override var description: String {
			var str = ""
			
			switch (op) {
			case .dps_arc:
				str = "<SNUserPathOperation: arc p1:\(point1.x),\(point1.y) r:\(radius) a1:\(angle1) a2:\(angle2)>"
				
			case .dps_arcn:
				str = "<SNUserPathOperation: arcn p1:\(point1.x),\(point1.y) r:\(radius) a1:\(angle1) a2:\(angle2)>"
				
			case .dps_arct:
				str = "<SNUserPathOperation: arct p1:\(point1.x),\(point1.y) p2:\(point2.x),\(point2.y)  r:\(radius)>"
				
			case .dps_closepath:
				str = "<SNUserPathOperation: closepath>";
				
			case .dps_curveto:
				str = "<SNUserPathOperation: curveto p1:\(point1.x),\(point1.y) p2:\(point2.x),\(point2.y) p3:\(point3.x),\(point3.y)>"
				
			case .dps_lineto:
				str = "<SNUserPathOperation: lineto p1:\(point1.x),\(point1.y)>"
				
			case .dps_moveto:
				str = "<SNUserPathOperation: moveto p1:\(point1.x),\(point1.y)>";
				
			case .dps_rcurveto:
				str = "<SNUserPathOperation: rcurveto p1:\(point1.x),\(point1.y) p2:\(point2.x),\(point2.y) p3:\(point3.x),\(point3.y)>"
				
			case .dps_rlineto:
				str = "<SNUserPathOperation: rlineto p1:\(point1.x),\(point1.y)>";
				
			case .dps_rmoveto:
				str = "<SNUserPathOperation: rmoveto p1:\(point1.x),\(point1.y)>";
				
			case .dps_setbbox:
				str = "<SNUserPathOperation: setbbox p1:\(point1.x),\(point1.y) p2:\(point2.x),\(point2.y)>"
				
			case .dps_ucache:
				str = "<SNUserPathOperation: ucache>";
				
				//default:
				//	str = "<SNUserPathOperation: UNKNOWN>";
			}
			
			return str;
		}
	}
	
	private var operations = [Operation]()
	
	//----------------------------------------------------------------------
	
	override init() {
		super.init()
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(operations)
	}
	
	init?(coder aDecoder: NSCoder) {
		operations = aDecoder.decodeObject() as? NSArray as? [Operation] ?? []
		super.init()
	}
	
	func toBezierPath() -> NSBezierPath {
		let path = NSBezierPath()
		for op in operations {
			op.applyToBezierPath(path)
		}
		return path
	}
	
	override var description: String {
		return operations.description
	}
}
