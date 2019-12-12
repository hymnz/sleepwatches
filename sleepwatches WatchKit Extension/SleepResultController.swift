//
//  SleepResultController.swift
//  Tracking WatchKit Extension
//
//  Created by pongsil vachirajongkol on 5/12/2562 BE.
//  Copyright © 2562 timecapsule. All rights reserved.
//

import WatchKit
import HealthKit

class SleepResultController: WKInterfaceController {
    let healthStore = HKHealthStore()
    var startDate : Date = Date()
    var endDate : Date = Date()
    
    @IBOutlet weak var resultTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext:context)
        let date = context as? [Date]

        self.startDate = Date.yesterday
        self.endDate = date?[1] ?? Date()
    }
    
    override func willActivate() {
        super.willActivate()
        setupTrackingSleep()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
}
