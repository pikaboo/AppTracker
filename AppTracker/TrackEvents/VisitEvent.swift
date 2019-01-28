//
//  VisitEvent.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 26/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit
import CoreLocation
class VisitEvent:NSObject, Codable {
    let logDate:String = Date().toString()
    let name:String! = "VisitEvent"
    let arrivalDate: String!
    let departureDate:String!
    let horizontalAccuracy:Double!
    let coordinate:Coordinate!
    
    init(visit:CLVisit) {
        self.arrivalDate = visit.arrivalDate.toString()
        self.departureDate = visit.departureDate.toString()
        self.coordinate = Coordinate(lat: visit.coordinate.latitude, lng: visit.coordinate.longitude)
        self.horizontalAccuracy = visit.horizontalAccuracy
    }
}


