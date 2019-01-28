//
//  TrackManager.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 25/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit
import CoreMotion

extension TrackManager {
    static let Tracking = "Tracking"
    static let LastActivityDate = "LastActivityDate"
    static let LastKnownLocation = "LastKnownLocation"
}
class TrackManager: NSObject,TrackEventListener{

    //ATFileManager is able to store codable objects to text file
    //As a list of normal json objects
    fileprivate var atFileManager:ATFileManager!
    
    //ATLocationManager handles everything for tracking location
    fileprivate var atLocationManager:ATLocationManager!
    
    //ATMotionActivityManager handles the Core Motion events
    fileprivate var atMotionActivityManager:ATMotionActivityManager!
    
    //Store background fetch handler, to complete background fetches
    fileprivate var backgroundFetchCompletionHandler:((UIBackgroundFetchResult) -> Void)?
    fileprivate var backgroundFetchTimeoutWorkItem:DispatchWorkItem!
    fileprivate var backgroundFetchInProgress = false
    fileprivate let backgroundFetchTimeoutSeconds:TimeInterval = 25
    
    fileprivate var userDefaults:UserDefaults!
    
    var fileName:String = "AppTrackerLog.txt"

    //store the tracking status between application runs
    var isTracking:Bool {
        set(newValue){
            self.userDefaults.set(newValue, forKey: TrackManager.Tracking)
        }
        get{
            return self.userDefaults.bool(forKey: TrackManager.Tracking)
        }
    }
    
    
     init(userDefaults:UserDefaults) {
        super.init()
        self.userDefaults = userDefaults
        self.atFileManager = ATFileManager()
        self.atFileManager.cacheDir = .documentDirectory
        self.atLocationManager = ATLocationManager(userDefaults: userDefaults,listener:self)
        self.atMotionActivityManager = ATMotionActivityManager(userDefaults: userDefaults, listener: self)
    }
    
    /*
     turn tracking on or off
     @param vc - UIViewController to display the dialog for requesting location in
     in case the location is off, and need to send the user to the settings app
    */
    func toggleTracking(in vc:UIViewController){
        self.isTracking = !self.isTracking
        
        if self.isTracking {
            self.beginTracking(in:vc)
        }else {
            self.endTracking()
        }
    }
    
    fileprivate func beginTracking(in vc:UIViewController){
        self.atLocationManager.startListeningToLocation(in: vc)
        self.checkActivityHistory()
    }
    
    fileprivate func endTracking(){
        self.endUpdates()
    }
    
    /**
     pass the background fetch callback, to handle all the logic in the manager
     rather than the app delegate
   */
    func onBackgroundFetchEvent(backgroundFetchHandler:@escaping (UIBackgroundFetchResult) -> Void){
        if !self.isTracking {
            backgroundFetchHandler(.noData)
            return
        }
        log("start background fetch")
        self.backgroundFetchCompletionHandler = backgroundFetchHandler
        self.backgroundFetchInProgress = true
        //The requirement is to get the most accurate location when background fetch occurs
        //Requesting the current location may result in background fetch timeout
        //As there is limited time for it to run.
        //Schedule a background fetch timeout task to execute with the previously known
        //location if the location request takes beyond some given time
        self.backgroundFetchTimeoutWorkItem = DispatchWorkItem {[weak self]  in
            if let strongSelf = self {
                log("finish time out")

                strongSelf.completeBackgroundFetch(coordinate: strongSelf.atLocationManager.lastKnownLocation, backgroundFetchHandler: backgroundFetchHandler)
            }
        }
        if !self.atLocationManager.isLocationAuthorized() {
            //If the user has not allowed to use location, then there is no need to wait for
            //The location update, just complete the request with the last known coordinate
            log("location not available")

            DispatchQueue.global().async(execute: self.backgroundFetchTimeoutWorkItem)
            return
        }

        log("set timout to complete background fetch")
        //If the location update did not arrive in time, send the background fetch with the last known location
        DispatchQueue.global().asyncAfter(deadline: .now() + self.backgroundFetchTimeoutSeconds, execute: self.backgroundFetchTimeoutWorkItem)
        log("request location")
        //get the current location
        self.atLocationManager.requestLocation()
    }
    
    fileprivate func completeBackgroundFetch(coordinate:Coordinate, backgroundFetchHandler:@escaping (UIBackgroundFetchResult) -> Void){
        log("completing background fetch")
        //Cancel the background fetch timeout task, because we are currently finishing up
        //the task
        log("background fetch timeout cancelled")
        self.backgroundFetchTimeoutWorkItem.cancel()
        self.backgroundFetchTimeoutWorkItem = nil
        let backgroundFetchEvent = BackgroundFetchEvent(coordinate:coordinate)
        self.atFileManager.storeObjectToFile(object: backgroundFetchEvent, filename: self.fileName) {[weak self]
            completed in
            self?.backgroundFetchInProgress = false
            log("background fetch completed")
            backgroundFetchHandler(.noData)
        }
    }

    func beginUpdates(){
        log("begin updates")
        self.atLocationManager.beginUpdates()
        self.checkActivityHistory()
    }
    
    func endUpdates(){
        self.atLocationManager.endUpdates()
        log("end updates")
    }

    func checkActivityHistory(){
        //Invoke checking of the previously done core motion activities
        self.atMotionActivityManager.checkActivityHistory()
    }
    
    
    func onVisitEvent(visitEvent: VisitEvent) {
        //Visit event recording
        atFileManager.storeObjectToFile(object: visitEvent, filename: self.fileName)
    }
    
    func onLocationEvent(locationEvent: LocationEvent) {
        if self.backgroundFetchInProgress {
            //If there is a background fetch event happening, then take the last known location, which by now has been updated to the newest value
                self.atLocationManager.lastKnownLocation = locationEvent.coordinate
                log("received location point:\(String(describing: self.atLocationManager.lastKnownLocation.lat)) \(String(describing: self.atLocationManager.lastKnownLocation.lng))")
                self.completeBackgroundFetch(coordinate: self.atLocationManager.lastKnownLocation, backgroundFetchHandler: self.backgroundFetchCompletionHandler!)
        }else {
            //Signification location change event recording
            atFileManager.storeObjectToFile(object: locationEvent, filename: self.fileName)
        }
    }
    
    func onErrorLocationEvent() {
        if self.backgroundFetchInProgress {
            //In case the location requeest failed, don't wait for the timeout
            //complete the background fetch now
            log("error location point")
            self.completeBackgroundFetch(coordinate: self.atLocationManager.lastKnownLocation, backgroundFetchHandler: self.backgroundFetchCompletionHandler!)
        }
    }
    
    func onMotionActivityEvent(motionActivities: [MotionActivityEvent]) {
        //This can receive an array of events, and store it as an array in the resulting
        //text file
        atFileManager.storeObjectToFile(object: motionActivities, filename: self.fileName)
    }
}
