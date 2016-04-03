//
//  Updater.swift
//  MatTest
//
//  Created by Cooper Knaak on 1/25/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation

public class Updater: NSObject {
   
    public var backgroundThread:NSThread? = nil
    private var updateTimer:NSTimer? = nil
    
    private var currentDate = NSDate()
    
    public let deltaTime:CGFloat = 1.0 / 60.0
    private var active = false
    public var isActive:Bool { return self.active }
    
    public var updateBlock:((CGFloat) -> ())? = nil
    
    public var totalDT:CGFloat = 0.0
    public var dtCount = 0
    public var averageDT:CGFloat {
        if (dtCount <= 0) {
            return 0
        } else {
            return totalDT / CGFloat(dtCount)
        }
    }
    
    override init() {
        
        super.init()
        
    }//initialize
    
    public func start() {
        
        self.stop()
        
        
        self.backgroundThread = NSThread(target: self, selector: #selector(mainThreadMethod), object: nil)
        self.backgroundThread?.start()
        self.active = true
        
    }//start
    
    public func stop() {
        
        self.backgroundThread?.cancel()
        self.backgroundThread = nil
        self.updateTimer?.invalidate()
        self.updateTimer = nil
        self.active = false
        
    }//stop
    
    public func mainThreadMethod(thread:NSThread) {
        
        let runLoop = NSRunLoop.currentRunLoop()
        
        let uTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.deltaTime), target: self, selector: #selector(mainThreadMethod), userInfo: nil, repeats: true)
        self.updateTimer = uTimer
        
        self.currentDate = NSDate()
        runLoop.run()
    }//main thread method
    
    public func mainTimerMethod(timer:NSTimer) {
        
        let dt = CGFloat(NSDate().timeIntervalSinceDate(self.currentDate))
        self.totalDT += dt
        self.dtCount += 1
        self.currentDate = NSDate()
        
        self.updateBlock?(dt)
    }//main timer method
    
}
