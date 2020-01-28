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
        self.altitude = nil
        
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            //TODO: Show error alert
            return
        }
        
        let queue = OperationQueue()
        queue.qualityOfService = .background
        
        altimeter.startRelativeAltitudeUpdates(to: queue) { (altimeterData, error) in
            if let altimeterData = altimeterData {
                let relativeAltitude        = altimeterData.relativeAltitude as! Double
                let roundedAltitude         = Int(relativeAltitude.roundToDecimal(2))
                self.altitude = roundedAltitude
            }
        }
    }
    
    func startTrackingMotionChanges() {
        
        motionManager.gyroUpdateInterval = self.timeInterval
        motionManager.accelerometerUpdateInterval = self.timeInterval
        
        self.accelero = nil
        self.gyro = nil
        
        if motionManager.isDeviceMotionAvailable {
            let coreMotionHandler : CMDeviceMotionHandler = {(data: CMDeviceMotion?, error: Error?) -> Void in
                if let data = data {
                    self.accelero = data.userAcceleration
                    self.gyro = data.rotationRate
                    
                }
            }
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: coreMotionHandler)
        } else {
            //notify user that no data is available
        }
    }
}
