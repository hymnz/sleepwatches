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

class InterfaceController: WKInterfaceController {
    
    let healthStore = HKHealthStore()
    var workoutSession : HKWorkoutSession?
    var builder : HKLiveWorkoutBuilder?
    let altimeter:CMAltimeter = CMAltimeter()
    let locationManager:CLLocationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    var timerValidateSession = Timer()
    var apiNetwork : Network!
    
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var gpsLabel: WKInterfaceLabel!
    @IBOutlet weak var speedLabel: WKInterfaceLabel!
    @IBOutlet weak var altitudeLabel: WKInterfaceLabel!
    @IBOutlet weak var acceleroXLabel: WKInterfaceLabel!
    @IBOutlet weak var acceleroYLabel: WKInterfaceLabel!
    @IBOutlet weak var acceleroZLabel: WKInterfaceLabel!
    @IBOutlet weak var gyroXLabel: WKInterfaceLabel!
    @IBOutlet weak var gyroYLabel: WKInterfaceLabel!
    @IBOutlet weak var gyroZLabel: WKInterfaceLabel!
    
    var id = ""
    var heartRate = ""
    var latitude = ""
    var longitude = ""
    var speed = ""
    var altitude = ""
    var acceleroX = ""
    var acceleroY = ""
    var acceleroZ = ""
    var gyroX = ""
    var gyroY = ""
    var gyroZ = ""
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.apiNetwork = Network(host: Constant.HOST )
        
        motionManager.gyroUpdateInterval = 0.1
        motionManager.accelerometerUpdateInterval = 0.1
        
    }
    
    override func willActivate() {
        super.willActivate()
        
        checkLocationServices()
        startTrackingAltitudeChanges()
        startTrackingAccelerometerChanges()
        startTrackingGyroChanges()
        startTrackingHeartRate()
        
        startValidateSession()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        self.locationManager.stopUpdatingLocation()
        self.altimeter.stopRelativeAltitudeUpdates()
        self.motionManager.stopAccelerometerUpdates()
        
        self.builder?.endCollection(withEnd: Date(), completion: { (success, error) in
            
        })
        self.builder?.finishWorkout(completion: { (workout, error) in
            
        })
        self.workoutSession?.end()
        
        self.stopValidateSession()
    }

    func stopValidateSession() {
        if timerValidateSession.isValid{
            timerValidateSession.invalidate()
        }
    }
    
    func startValidateSession() {
        self.stopValidateSession()
        timerValidateSession = Timer.scheduledTimer(timeInterval: Constant.TIME_INTERVAL, target: self, selector: #selector(requestDailyTrack), userInfo: nil, repeats: true);
    }
    
    func encrypt(_ string:String) -> String {               // 16 bytes for AES128
        let aes256 = AES(key: Constant.KEY256, iv: Constant.IV)
        let encryptedPassword256 = aes256?.encrypt(string: string)
        return encryptedPassword256?.base64EncodedString() ?? ""
    }
    
    @objc func requestDailyTrack() {
        
        var param :[String:Any] = ["userId": UUIDGenerator.sharedInstance.string]
        param["ts"] = Date().timeIntervalSince1970
        
        var payload :[String:Any] = [:]
        
        if (!heartRate.isEmpty) {
            payload["hr"] = encrypt(heartRate)
        }
        
        if (!longitude.isEmpty && !latitude.isEmpty) {
            payload["geo"] = ["long":encrypt(longitude),"lat":encrypt(latitude)]
        }
        
        if (!acceleroX.isEmpty && !acceleroY.isEmpty && !acceleroZ.isEmpty) {
            payload["acc"] = ["x":encrypt(acceleroX),"y":encrypt(acceleroY),"z":encrypt(acceleroZ)]
        }
        
        if (!gyroX.isEmpty && !gyroY.isEmpty && !gyroZ.isEmpty) {
            payload["gyr"] = ["x":encrypt(gyroX),"y":encrypt(gyroY),"z":encrypt(gyroZ)]
        }
        
        if (!speed.isEmpty) {
            payload["speed"] = encrypt(speed)
        }
        
        if (!altitude.isEmpty) {
            payload["altitude"] = encrypt(altitude)
        }
        
        param["payload"] = payload
        
        apiNetwork.post(path: "/daily/track", params: param ){ (data, error) in
            
            guard let data = data else {
                return
            }
            
            guard let httpResponse = data.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {

                return
            }
            
            let json:(data: Dictionary<String, Any>?, error: NetworkError?) = data.jsonObject()
            
            if let _ = json.error {
                return
            }
        }
    }
}
