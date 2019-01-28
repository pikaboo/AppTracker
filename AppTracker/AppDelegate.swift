//
//  AppDelegate.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 25/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let trackManager:TrackManager! = TrackManager(userDefaults: UserDefaults.standard)
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if trackManager.isTracking {
          trackManager.beginUpdates()
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if trackManager.isTracking {
            trackManager.checkActivityHistory()
        }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.trackManager.onBackgroundFetchEvent(backgroundFetchHandler: completionHandler)
    }

}

