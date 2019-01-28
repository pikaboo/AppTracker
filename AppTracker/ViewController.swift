//
//  ViewController.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 25/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var trackButton: UIButton!
    var trackManager :TrackManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.trackManager = TrackManager(userDefaults: UserDefaults.standard)
        self.updateTrackingStatus()
    }

    @IBAction func toggleTracking(_ sender: Any) {
        self.trackManager.toggleTracking(in:self)
        self.updateTrackingStatus()
    }
    
    func updateTrackingStatus(){
        if self.trackManager.isTracking {
            self.trackButton.setTitle("Stop Tracking", for: .normal)
        }else {
            self.trackButton.setTitle("Start Tracking", for: .normal)
        }
    }
    
}

