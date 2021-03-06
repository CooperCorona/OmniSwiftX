//
//  FluctuatingNoise1D.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 10/13/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation

public class FluctuatingNoise1D: CustomStringConvertible {
    
    // MARK: - Properties
    
    public let noise:NoiseArray1D
    
    ///The internal time used to calculate the noise.
    public private(set) var time:CGFloat = 0.0
    ///The speed at which the time increases (negative values cause the time to decrease).
    public var speed:CGFloat = 1.0
    ///The middle value of the noise.
    public var middleValue:CGFloat = 0.0
    ///The range of the values.
    public var range:CGFloat = 2.0
    ///The lower value of the noise.
    public var lowerValue:CGFloat {
        get {
            return self.middleValue - self.range / 2.0
        }
        set {
            self.middleValue = newValue + self.range / 2.0
        }
    }
    ///The lower and upper value of the noise.
    public var extremeValues:(low:CGFloat, hi:CGFloat) {
        get {
            return (self.lowerValue, self.lowerValue + self.range)
        }
        set {
            self.range = newValue.hi - newValue.low
            self.lowerValue = newValue.low
        }
    }
    
    ///The value the noise is divided by to fix its range to [-1.0, 1.0].
    public let noiseDivisor:CGFloat = 0.7
    
    ///The type of noise used.
    public var noiseType = GLSPerlinNoiseSprite.NoiseType.Default
    
    private var storedValue:CGFloat = 0.0
    public var value:CGFloat {
        switch self.noiseType {
        case .Default:
            return self.noise.noiseAt(self.time) / self.noiseDivisor * self.range + self.middleValue
        case .Fractal:
            return self.baseNoise(4) / self.noiseDivisor * self.range + self.middleValue
        case .Abs:
            return abs(self.baseNoise(4) / self.noiseDivisor) * self.range + self.middleValue
        case .Sin:
            let val = abs(self.baseNoise(4) / self.noiseDivisor) * self.range + self.middleValue
            return sin(CGFloat(M_PI) * self.time + val)
        }
    }
    
    public var description:String { return "Noise(\(self.noise.seed)) \(self.extremeValues)" }
    
    // MARK: - Setup
    
    ///Initialize with a random seed.
    public convenience init() {
        self.init(noise: NoiseArray1D())
    }
    
    ///Initialize with a specific Noise object.
    public init(noise:NoiseArray1D) {
        self.noise = noise
    }
    
    ///Initialize with a specific Noise object with a given seed.
    public convenience init(seed:UInt32) {
        self.init(noise: NoiseArray1D(seed: seed))
    }
    
    // MARK: - Logic
    
    ///Update the time given a delta.
    public func update(dt:CGFloat) {
        self.time += self.speed * dt
    }
    
    private func baseNoise(iterations:Int) -> CGFloat {
        var noiseValue:CGFloat = 0.0
        for i in 1...iterations {
            let factor = CGFloat(1 << i)
            noiseValue += self.noise.noiseAt(self.time * factor) / factor
        }
        return noiseValue
    }
}
