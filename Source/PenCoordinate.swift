//
//  PenCoordinate.swift
//  SinterPixelsBridge
//
//  Created by Olof Hellman on 7/12/26.
//


import Foundation

public class PenCoordinate {
    var coords: [Int: PenPair]
    public init () {
        self.coords = [:]
    }
    
    public init (axis: Int, penPair: PenPair) {
        self.coords = [axis:penPair]
    }

    public init(axisA: Int, penPairA: PenPair, axisB: Int, penPairB: PenPair) {
        self.coords = [axisA: penPairA, axisB: penPairB]
    }
    
    public static func origin() -> PenCoordinate {
        return PenCoordinate()
    }
    
    public func setAxis(index: Int, penPair: PenPair) {
        self.coords[index] = penPair
    }

    public func getAxis(index: Int) -> PenPair {
        return self.coords[index] ?? PenPair(w: 0, n: 0)
    }

    //return the sum of all axes as a new PenCoordinate
    public func add(pc: PenCoordinate) -> PenCoordinate {
        let sum = PenCoordinate()
        for i in 0...4 {
            let penPair = getAxis(index: i)
            let otherPenPair = pc.getAxis(index: i)
            let ithPenPair = PenPair(w: penPair.W + otherPenPair.W, n: penPair.N + otherPenPair.N)
            sum.setAxis(index: i, penPair: ithPenPair);
        }
        return sum
    }
    
    //return the difference of all axes as a new PenCoordinate
    public func subtract(pc: PenCoordinate) -> PenCoordinate {
        let diff = PenCoordinate()
        for i in 0...4 {
            let penPair = getAxis(index: i)
            let otherPenPair = pc.getAxis(index: i)
            let ithPenPair = PenPair(w: penPair.W - otherPenPair.W, n: penPair.N - otherPenPair.N)
            diff.setAxis(index:i, penPair: ithPenPair);
        }
        return diff
     }

    // penPair is in axis zero
    // express it in terms of axis1 and axis2
    // returns two item array of PenPair, first is axis1, second is axis2
    static public func expressCoordInAxes(penPair: PenPair, axis1: Int, axis2: Int) -> (PenPair, PenPair)? {
        if (axis1 == axis2) {
            return nil
        }
        if (axis1 == 0) {
            return (penPair, PenPair())
        }

        if (axis2 == 0) {
            return (PenPair(), penPair)
        }
        
        if (axis2 < axis1) {
            guard let switchedResult = PenCoordinate.expressCoordInAxes(penPair: penPair, axis1: axis2, axis2: axis1) else {
                return nil
            }
            return (switchedResult.1, switchedResult.0)
        }

        if ((axis1 == 1) && (axis2 == 2)) {
            // if N>W, inexpressible
            // each N,W pair (count = N) contributes axis1:W and axis2:-WN
            // each W (count = W-N) contributes axis1:N and axis2:-W
            let wMinusN = penPair.W - penPair.N;
            return (PenPair(w: penPair.N, n: wMinusN), PenPair(w: (-wMinusN) - penPair.N, n: -penPair.N))
        }

        if ((axis1 == 1) && (axis2 == 3)) {
            // each N contributes axis1:-N and axis2:-W
            // each W contributes axis1:-W and axis2:-WN
            return (PenPair(w: -penPair.W, n: -penPair.N), PenPair(w: -(penPair.W + penPair.N), n: -penPair.W))
        }
        if ((axis1 == 1) && (axis2 == 4)) {
             // each N contributes axis1:W and axis2:W
              // each W contributes axis1:W,N and axis2:W,N
            return (PenPair(w: penPair.W + penPair.N, n: penPair.W), PenPair(w: penPair.W + penPair.N, n: penPair.W))
        }

        if ((axis1 == 2) && (axis2 == 3)) {
            // each W (count W-N) contributes axis1:-N and axis2:-N
            // each WN pair (count N) axis1:-W and axis2:-W
            // if N>W, inexpressible
            let wMinusN = penPair.W - penPair.N;
            return (PenPair(w: -wMinusN, n: -penPair.W),  PenPair(w: -wMinusN, n: -penPair.W))
        }
   
        if ((axis1 == 2) && (axis2 == 4)) {
            // mirror image of 1,3
            // each N contributes axis1:-W and axis2:-N
            // each W contributes axis1:-WN and axis2:-W
            return (PenPair(w: -(penPair.W + penPair.N), n: -penPair.W), PenPair(w: -penPair.W, n: -penPair.N))

        }

        if ((axis1 == 3) && (axis2 == 4)) {
             // mirror image of 1,2
            // each N,W pair (count = N) contributes axis1:-WN and axis2:W
            // each W (count = W-N) contributes axis1:-W and axis2:N
            let wMinusN = penPair.W - penPair.N;
            return (PenPair(w:(-wMinusN) - penPair.N, n: -penPair.N), PenPair(w: penPair.N, n: wMinusN))
        }

        return nil
    
    }

    // pass in two axis values and return a new PenCoordinate that expresses this coordinate in terms of those axes
    // returns pair of PenPair
    public static func expressAxisCoordInAxes(axis: Int, penPair: PenPair, axis1: Int, axis2: Int) -> (PenPair, PenPair)? {
        // the answer is symmetric for all the axes
        let diff = axis - 1;
        var newAxis1 = axis1 - diff;
        if (newAxis1 < 0) {
            newAxis1 += 5
        }
        var newAxis2 = axis2 - diff
        if (newAxis2 < 0) {
            newAxis2 += 5
        }
        return expressCoordInAxes(penPair: penPair, axis1: newAxis1, axis2: newAxis2)
    }

    // pass in two axis values
    // returns a new PenCoordinate that expresses this coordinate in terms of those axes
    public func expressInAxes(axis1: Int, axis2: Int) -> PenCoordinate {
        var axis1PenPair = PenPair()
        var axis2PenPair = PenPair()
        for (ithAxis, ithPenPair) in coords {
            if let pairOfPenPairs = PenCoordinate.expressAxisCoordInAxes(axis: ithAxis, penPair: ithPenPair, axis1: axis1, axis2: axis2) {
                axis1PenPair = axis1PenPair.add(pairOfPenPairs.0)
                axis2PenPair = axis2PenPair.add(pairOfPenPairs.1)
            }
        }
        return PenCoordinate(axisA: axis1, penPairA: axis1PenPair, axisB: axis2, penPairB: axis2PenPair)
    }

    public var A: PenPair {
        get {
            return coords[0] ??  PenPair(w:0, n:0)
        }
        set {
            coords[0] = newValue
        }
   }

    public var B: PenPair {
        get {
        return coords[1] ??  PenPair(w:0, n:0)
        }
        set {
            coords[1] = newValue
        }
    }

    public var C: PenPair {
        get {
        return coords[2] ?? PenPair(w:0, n:0)
        }
        set {
            coords[2] = newValue
        }
    }

    public var D: PenPair {
        get {
        return coords[3] ?? PenPair(w:0, n:0)
        }
        set {
            coords[3] = newValue
        }
   }

    public var E: PenPair {
        get {
            return coords[04] ?? PenPair(w:0, n:0)
        }
        set {
            coords[4] = newValue
        }
    }
 
}
