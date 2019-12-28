//
//  SleepTrackController.swift
//  Tracking WatchKit Extension
//
//  Created by pongsil vachirajongkol on 5/12/2562 BE.
//  Copyright © 2562 timecapsule. All rights reserved.
//

import WatchKit

class SleepTrackController: WKInterfaceController {
    
    @IBOutlet weak var detailGroup: WKInterfaceGroup!
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var stopButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func startAction() {
        let startDate = Date()
        UserDefaults.standard.set(startDate, forKey: "startDate")
        UserDefaults.standard.synchronize()
        self.detailGroup.setHidden(false)
        self.startButton.setHidden(true)
        self.stopButton.setHidden(false)
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        
        let endDate = Date()
        UserDefaults.standard.set(endDate, forKey: "endDate")
        UserDefaults.standard.synchronize()
        self.detailGroup.setHidden(true)
        self.startButton.setHidden(false)
        self.stopButton.setHidden(true)
        return nil
    }
}
