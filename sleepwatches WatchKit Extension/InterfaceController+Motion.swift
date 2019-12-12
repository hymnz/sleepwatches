//
//  InterfaceController + Health.swift
//  tracking WatchKit Extension
//
//  Created by pongsil vachirajongkol on 16/11/2562 BE.
//  Copyright © 2562 timecapsule. All rights reserved.
//

import CoreMotion

extension InterfaceController {
    
    func startTrackingAltitudeChanges() {
        self.altitudeLabel.setText("-")
        self.altitude = ""
        
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            //TODO: Show error alert
            return
        }
        
        let queue = OperationQueue()
        queue.qualityOfService = .background
        
        altimeter.startRelativeAltitudeUpdates(to: queue) { (altimeterData, error) in
            if let altimeterData = altimeterData {
                DispatchQueue.main.async {
                    let relativeAltitude        = altimeterData.relativeAltitude as! Double
                    let roundedAltitude         = Int(relativeAltitude.roundToDecimal(2))
                    self.altitudeLabel.setText("\(roundedAltitude)m")
                    self.altitude = "\(roundedAltitude)"
                }
            }
        }
    }
}
