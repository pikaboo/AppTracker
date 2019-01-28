//
//  AlertManager.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 27/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit
import CoreLocation
class AlertManager: NSObject {

    /**
     display a dialog announcing something, and send useer to the location seettings in the settings app
 */
    func showLocationAlert(in vc:UIViewController, title:String, message:String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default){
            action in
            if !CLLocationManager.locationServicesEnabled() {
                if let url = URL(string: "App-Prefs:root==LOCATION") {
                    // If general location settings are disabled then open general location settings
                    UIApplication.shared.open(url, options: [:], completionHandler: { (Bool) in
                        log("opened settings")
                    })
                }
            } else {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    // If general location settings are enabled then open location settings for the app
                    UIApplication.shared.open(url, options: [:], completionHandler: { (Bool) in
                        log("opened settings")
                    })
                }
            }
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
    }
}

