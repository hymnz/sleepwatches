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
    
    var timerValidateSession = Timer()
    var apiNetwork : Network!
    
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var gpsLabel: WKInterfaceLabel!
    @IBOutlet weak var speedLabel: WKInterfaceLabel!
    @IBOutlet weak var altitudeLabel: WKInterfaceLabel!
    
    var id = ""
    var heartRate = ""
    var latitude = ""
    var longitude = ""
    var speed = ""
    var altitude = ""
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.apiNetwork = Network(host: Constant.HOST )
        
    }
    
    override func willActivate() {
        super.willActivate()
        
        checkLocationServices()
        startTrackingAltitudeChanges()
        
        startTrackingHeartRate()
        
        startValidateSession()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        self.locationManager.stopUpdatingLocation()
        self.altimeter.stopRelativeAltitudeUpdates()
        self.builder?.endCollection(withEnd: Date(), completion: { (success, error) in
            
        })
        self.builder?.finishWorkout(completion: { (workout, error) in
            
        })
        self.workoutSession?.end()
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
        
        let param :[String:Any] = ["id": UUIDGenerator.sharedInstance.string,"datetime": encrypt(Date().toCurrentTimeZoneString()),"heartRate": encrypt(heartRate),"longitude": encrypt(longitude),"latitude": encrypt(latitude),"speed": encrypt(speed),"altitude": encrypt(altitude)]
        
        print(param)
        
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
