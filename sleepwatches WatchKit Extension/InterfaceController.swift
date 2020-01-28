//
//  InterfaceController.swift
//  tracking WatchKit Extension
//
//  Created by pongsil vachirajongkol on 15/11/2562 BE.
//  Copyright © 2562 timecapsule. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import HealthKit
import CoreMotion

class InterfaceController: WKInterfaceController,WatchKitConnectionDelegate {
    let healthStore = HKHealthStore()
    var workoutSession : HKWorkoutSession?
    var builder : HKLiveWorkoutBuilder?
    let altimeter:CMAltimeter = CMAltimeter()
    let locationManager:CLLocationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    var timerValidateSession = Timer()
    
    @IBOutlet weak var intervalLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var stopButton: WKInterfaceButton!
    
    
    var id = ""
    var heartRate :Double? = nil
    var location :CLLocation? = nil
    var altitude :Int? = nil
    var accelero :CMAcceleration? = nil
    var gyro :CMRotationRate? = nil
    
    var timeInterval :TimeInterval = 5
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        WatchKitConnection.shared.startSession()
        WatchKitConnection.shared.delegate = self
    }
    
    func didReceiveInterval(_ interval: String) {
        self.timeInterval = TimeInterval(Int(interval) ?? 5)
    }
    
    @IBAction func startAction() {
        self.startButton.setHidden(true)
        self.stopButton.setHidden(false)
        
        checkLocationServices()
        startTrackingAltitudeChanges()
        startTrackingMotionChanges()
        startTrackingHeartRate()

        startDataTimer()
    }
    
    @IBAction func stopAction() {
        self.startButton.setHidden(false)
        self.stopButton.setHidden(true)
        
        self.locationManager.stopUpdatingLocation()
        self.altimeter.stopRelativeAltitudeUpdates()
        self.motionManager.stopAccelerometerUpdates()

        self.builder?.endCollection(withEnd: Date(), completion: { (success, error) in

        })
        self.builder?.finishWorkout(completion: { (workout, error) in

        })
        self.workoutSession?.end()

        self.stopDataTimer()
    }

    func stopDataTimer() {
        if timerValidateSession.isValid{
            timerValidateSession.invalidate()
        }
        self.intervalLabel.setHidden(true)
    }
    
    func startDataTimer() {
        self.stopDataTimer()
        self.intervalLabel.setText("\(self.timeInterval)")
        self.intervalLabel.setHidden(false)
        timerValidateSession = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(sendDataToPhone), userInfo: nil, repeats: true);
    }
    
    @objc func sendDataToPhone() {

        var payload :[String:Any] = [:]
        
        if let heartRate = self.heartRate {
            payload["hr"] = heartRate
        }
        if let location = self.location {
            payload["geo"] = ["long":location.coordinate.longitude,"lat":location.coordinate.latitude]
            payload["speed"] = location.speed
        }
        if let accelero = self.accelero {
            payload["acc"] = ["x":accelero.x,"y":accelero.y,"z":accelero.z]
        }
        if let gyro = self.gyro {
            payload["gyr"] = ["x":gyro.x,"y":gyro.y,"z":gyro.z]
        }
        if let altitude = self.altitude {
            payload["altitude"] = altitude
        }
        WatchKitConnection.shared.sendMessage(message: ["trackData":
        payload as AnyObject])
    }
    
}
