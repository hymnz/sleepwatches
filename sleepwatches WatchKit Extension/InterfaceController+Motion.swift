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
    
    func startTrackingAccelerometerChanges() {
        self.acceleroXLabel.setText("-")
        self.acceleroYLabel.setText("-")
        self.acceleroZLabel.setText("-")
        self.acceleroX = ""
        self.acceleroY = ""
        self.acceleroZ = ""
        self.gyroXLabel.setText("-")
        self.gyroYLabel.setText("-")
        self.gyroZLabel.setText("-")
        self.gyroX = ""
        self.gyroY = ""
        self.gyroZ = ""
        
        if motionManager.isDeviceMotionAvailable {
            let coreMotionHandler : CMDeviceMotionHandler = {(data: CMDeviceMotion?, error: Error?) -> Void in
                if let data = data {
                    self.acceleroXLabel.setText(String(format: "X : %.2f", data.userAcceleration.x))
                    self.acceleroX = String(format: "%.2f", data.userAcceleration.x)
                    self.acceleroYLabel.setText(String(format: "Y : %.2f", data.userAcceleration.y))
                    self.acceleroY = String(format: "%.2f", data.userAcceleration.y)
                    self.acceleroZLabel.setText(String(format: "Z : %.2f", data.userAcceleration.z))
                    self.acceleroZ = String(format: "%.2f", data.userAcceleration.z)
                    self.gyroXLabel.setText(String(format: "X : %.2f", data.rotationRate.x))
                    self.gyroX = String(format: "%.2f", data.rotationRate.x)
                    self.gyroYLabel.setText(String(format: "Y : %.2f", data.rotationRate.y))
                    self.gyroY = String(format: "%.2f", data.rotationRate.y)
                    self.gyroZLabel.setText(String(format: "Z : %.2f", data.rotationRate.z))
                    self.gyroZ = String(format: "%.2f", data.rotationRate.z)
                }
            }
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: coreMotionHandler)
        } else {
            //notify user that no data is available
        }
        
        
//        guard motionManager.isAccelerometerAvailable else {
//            //TODO: Show error alert
//            return
//        }
//
//        let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: Error?) -> Void in
//            if let data = data {
//                self.acceleroXLabel.setText(String(format: "X : %.2f", data.acceleration.x))
//                self.acceleroYLabel.setText(String(format: "Y : %.2f", data.acceleration.y))
//                self.acceleroZLabel.setText(String(format: "Z : %.2f", data.acceleration.z))
//                self.acceleroX = String(format: "%.2f", data.acceleration.z)
//                self.acceleroY = String(format: "%.2f", data.acceleration.y)
//                self.acceleroZ = String(format: "%.2f", data.acceleration.z)
//            } else {
//                self.acceleroXLabel.setText(error?.localizedDescription)
//            }
//        }
//        motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: handler)
    }
    
    func startTrackingGyroChanges() {
//        self.gyroXLabel.setText("-")
//        self.gyroYLabel.setText("-")
//        self.gyroZLabel.setText("-")
//        self.gyroX = ""
//        self.gyroY = ""
//        self.gyroZ = ""
//
//        guard motionManager.isGyroAvailable else {
//            //TODO: Show error alert
//            return
//        }
//
//        let handler:CMGyroHandler = {(data: CMGyroData?, error: Error?) -> Void in
//            if let data = data {
//                self.gyroXLabel.setText(String(format: "X : %.2f", data.rotationRate.x))
//                self.gyroYLabel.setText(String(format: "Y : %.2f", data.rotationRate.y))
//                self.gyroZLabel.setText(String(format: "Z : %.2f", data.rotationRate.z))
//                self.gyroX = String(format: "%.2f", data.rotationRate.x)
//                self.gyroY = String(format: "%.2f", data.rotationRate.y)
//                self.gyroZ = String(format: "%.2f", data.rotationRate.z)
//            }
//        }
//        motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: handler)
//    }
    }
}
