//
//  Coordinate.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 26/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit

class Coordinate:NSObject, Codable {
    var lat:Double!
    var lng:Double!
    
    init(lat:Double,lng:Double) {
        self.lat = lat
        self.lng = lng
    }
    
    static var zero = Coordinate(lat: 0, lng: 0)
    
}
