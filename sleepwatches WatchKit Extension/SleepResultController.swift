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
    
    var apiNetwork : Network!
    
    @IBOutlet weak var resultTable: WKInterfaceTable!
    @IBOutlet weak var errorLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext:context)
        let date = context as? [Date]

        self.startDate = date?[0] ?? Date()
        self.endDate = date?[1] ?? Date()
        
        self.apiNetwork = Network(host: Constant.HOST)
    }
    
    override func willActivate() {
        super.willActivate()
        setupTrackingSleep()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
}
