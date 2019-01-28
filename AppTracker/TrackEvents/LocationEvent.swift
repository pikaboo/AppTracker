//
//  LocationEvent.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 26/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit
import CoreLocation
class LocationEvent:NSObject, Codable {
    
    let name:String! = "LocationEvent"
    let logDate:String! = Date().toString()
    var coordinate:Coordinate!
    var altitude: Double!
    var horizontalAccuracy:Double!
    var verticalAccuracy:Double!
    var course:Double!
    var speed:Double!
    var timestamp:String!
    var floor:Int!
    
    
    init(location:CLLocation) {
        self.coordinate = Coordinate(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.course = location.course
        self.speed = location.speed
        self.timestamp = location.timestamp.toString()
        self.floor = location.floor?.level ?? 0
    }
}
