//
//  MotionActivityEvent.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 27/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit
import CoreMotion
class MotionActivityEvent: NSObject,Codable {

    let logDate: String! = Date().toString()
    let name: String! = "MotionActivityEvent"
    var activityType:String!
    var startDate:String!
    var confidence:Int!
    
    init(activity:CMMotionActivity) {
        self.startDate = activity.startDate.toString()
        if activity.unknown {
            self.activityType = "unknown"
        }
        if activity.stationary {
            self.activityType = "stationary"
        }
        
        if activity.walking {
            self.activityType = "walking"
        }
        
        if activity.running {
            self.activityType = "running"
        }
        
        if activity.automotive {
            self.activityType = "automotive"
        }
        self.confidence = activity.confidence.rawValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let activity = object as? MotionActivityEvent {
            return activity.startDate == self.startDate && activity.activityType == self.activityType
        }
        
        return false
    }
    override var hash: Int{
        return self.combineHashes([self.startDate.hash,self.activityType.hash])
    }
}
