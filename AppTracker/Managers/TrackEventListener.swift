//
//  TrackEventListener.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 27/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit

@objc protocol TrackEventListener {
    @objc optional func onLocationEvent(locationEvent:LocationEvent)
    @objc optional func onVisitEvent(visitEvent:VisitEvent)
    @objc optional func onErrorLocationEvent()
    @objc optional func onMotionActivityEvent(motionActivities:[MotionActivityEvent])

}
