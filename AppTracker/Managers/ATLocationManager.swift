//
//  ATLocationManager.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 27/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit
import CoreLocation
class ATLocationManager: NSObject,CLLocationManagerDelegate {
    
    fileprivate var _lastKnownLocation:Coordinate!
    fileprivate var userDefaults:UserDefaults!
    fileprivate var alertManager : AlertManager!
    fileprivate var locationManager: CLLocationManager!
    fileprivate weak var eventListner : TrackEventListener?
    
    var lastKnownLocation:Coordinate {
        set(newValue){
            _lastKnownLocation = newValue
            let jsonEncoder = JSONEncoder()
            do {
                let data = try jsonEncoder.encode(newValue)
                self.userDefaults.set(data, forKey: TrackManager.LastKnownLocation)
            }catch let error{
                print("unable to store coordinate in user defaults:\(String(describing: _lastKnownLocation)) error:\(error)")
            }
        }
        get{
            if _lastKnownLocation != nil {
                return _lastKnownLocation
            }
            let jsonDecoder = JSONDecoder()
            do {
                if let data = self.userDefaults.data(forKey: TrackManager.LastKnownLocation) {
                    let coordinate = try jsonDecoder.decode(Coordinate.self,from: data)
                    return coordinate
                }
            }catch let error{
                log("unable to read coordinate in user defaults:\(String(describing: _lastKnownLocation)) error:\(error)")
            }
            return Coordinate.zero
        }
    }
    
    init(userDefaults:UserDefaults, listener:TrackEventListener) {
        super.init()
        self.userDefaults = userDefaults
        self.alertManager = AlertManager()
        self.locationManager = CLLocationManager()
        self.eventListner = listener
    }
    
    func beginUpdates(){
        log("begin updates")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 35
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringVisits()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    
    func startListeningToLocation(in vc:UIViewController){
        let status  = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            return
        }
        if status == .authorizedWhenInUse {
            self.alertManager.showLocationAlert(in: vc, title: "Location Services Not enabled while app is not in use", message: "Please enable Always Location Services Access in Settings")
            return
        }
        
        if status == .denied || status == .restricted {
            self.alertManager.showLocationAlert(in: vc, title: "Location Services Not enabled", message: "Please enable Always Location Services Access in Settings")
            return
        }
        
        self.beginUpdates()
    }
    
    func endUpdates(){
        locationManager.stopMonitoringVisits()
        locationManager.stopMonitoringSignificantLocationChanges()
        log("end updates")
    }
    
    func requestLocation(){
        self.locationManager.requestLocation()
    }
    
    func isLocationAuthorized() -> Bool {
        let status  = CLLocationManager.authorizationStatus()
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let visitEvent = VisitEvent(visit: visit)
        log("visit")
        self.eventListner?.onVisitEvent?(visitEvent: visitEvent)
    }
    
  
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.eventListner?.onErrorLocationEvent?()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if isLocationAuthorized() {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let locationEvent = LocationEvent(location: location)
            self.eventListner?.onLocationEvent?(locationEvent: locationEvent)
        }
        
    }
}
