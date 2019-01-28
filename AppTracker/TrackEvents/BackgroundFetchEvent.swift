//
//  BackgroundFetchEvent.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 26/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit
class BackgroundFetchEvent:NSObject, Codable {

    let logDate:String! = Date().toString()
    let name:String! = "BackgroundFetchEvent"
    let locationCoordinate:Coordinate!

    init(coordinate:Coordinate) {
        self.locationCoordinate = coordinate
    }
}
