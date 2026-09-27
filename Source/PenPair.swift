//
//  PenPair.swift
//  SinterPixelsBridge
//
//  Created by Olof Hellman on 7/12/26.
//


import Foundation
public class PenPair {
    public let W: Int
    public let N: Int
    public init()  {
        self.W = 0
        self.N = 0
    }
    public init(w: Int, n: Int)  {
        self.W = w
        self.N = n
    }
    public func add(_ pp: PenPair) -> PenPair {
        return PenPair(w: W + pp.W, n: N + pp.N)
    }
}
