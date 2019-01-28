//
//  ATMotionActivityManager.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 27/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit
import CoreMotion
class ATMotionActivityManager: NSObject {

    fileprivate var userDefaults:UserDefaults!
    fileprivate var coreMotionActivityManager:CMMotionActivityManager!
    fileprivate var eventListener:TrackEventListener?
    fileprivate var operationQueue:OperationQueue!
    
    fileprivate var lastActivityDate:Date {
        set(newValue){
            self.userDefaults.set(newValue, forKey: TrackManager.LastActivityDate)
        }
        get {
            if let date = self.userDefaults.object(forKey: TrackManager.LastActivityDate)as? Date {
                return date
            }
            if let twoHoursAgo = Calendar.current.date(byAdding: .hour, value: -2, to: Date()) {
                return twoHoursAgo
            }
            return Date()
        }
    }
    init(userDefaults:UserDefaults, listener:TrackEventListener) {
        super.init()
        self.userDefaults = userDefaults
        self.eventListener = listener
        self.coreMotionActivityManager = CMMotionActivityManager()
        self.operationQueue = OperationQueue()
    }

    /**
     query recent core motion activity that came after lastactivitydate
    */
    func checkActivityHistory(){
        self.coreMotionActivityManager.queryActivityStarting(from: self.lastActivityDate, to: Date(), to: self.operationQueue) {[weak self] (activities, error) in
            
            guard let activities = activities else {
                return
            }
            var modes: [MotionActivityEvent] = []
            let lastActivityDate = self?.lastActivityDate
            activities.forEach({ (activity) in
                if activity.startDate.compare((lastActivityDate)!) == .orderedDescending {
                    let event = MotionActivityEvent(activity: activity)
                    if !modes.contains(event) {
                        modes.append(MotionActivityEvent(activity: activity))
                    }
                }
            })
            self?.lastActivityDate = Date()
            self?.eventListener?.onMotionActivityEvent?(motionActivities: modes)
        }
    }
    
}
