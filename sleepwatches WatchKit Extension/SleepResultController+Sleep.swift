//
//  InterfaceController + Health.swift
//  tracking WatchKit Extension
//
//  Created by pongsil vachirajongkol on 16/11/2562 BE.
//  Copyright © 2562 timecapsule. All rights reserved.
//

import HealthKit
import CoreMotion

extension SleepResultController {
    
    func setupTrackingSleep() {
        errorLabel.setHidden(true)
        let types = Set([HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
        
        healthStore.requestAuthorization(toShare: types, read: types) { (success, error) in
            guard success == true else {
                return
            }
        }
        
        self.saveSleepAnalysis()
        
    }
    
    func saveSleepAnalysis() {
        
        
        let manager = CMMotionActivityManager()
//        let calendar = Calendar.current
//
//        let startDate = calendar.date(byAdding: .hour, value: -13, to: Date.yesterday) ?? Date()
//        let date = calendar.date(byAdding: .hour, value: -4, to: Date.yesterday) ?? Date()
        
        manager.queryActivityStarting(from: startDate, to: endDate, to: .main){ activities, error in
            var lastSleepDate: Date? = nil
            var lastAwakeDate: Date? = nil

            self.saveSleepAnalysis(type: HKCategoryValueSleepAnalysis.inBed.rawValue, start: self.startDate, end: self.endDate)
            
            activities?.forEach { activity in
                if activity.stationary {
                    if lastSleepDate == nil {
                        lastSleepDate = activity.startDate
                    }
                    lastAwakeDate = nil
                } else {
                    if let startDate = lastSleepDate {
                        self.saveSleepAnalysis(type: HKCategoryValueSleepAnalysis.asleep.rawValue, start: startDate, end: activity.startDate)
                        lastSleepDate = nil
                    }
                    lastAwakeDate = activity.startDate
                }
            }
            if let startDate = lastSleepDate {
                self.saveSleepAnalysis(type: HKCategoryValueSleepAnalysis.asleep.rawValue, start: startDate, end: self.endDate)
            }
            if let startDate = lastAwakeDate {
                self.saveSleepAnalysis(type: HKCategoryValueSleepAnalysis.awake.rawValue, start: startDate, end: self.endDate)
            }
            
            self.retrieveSleepAnalysis()
            
        }
    }
    
    func saveSleepAnalysis(type: Int, start startDate: Date, end endDate: Date) {

        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            let sample = HKCategorySample(type: sleepType, value: type, start: startDate, end: endDate)
                healthStore.save(sample) { (success, error) in
            }
        }
    }
    
    func retrieveSleepAnalysis() {
        
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            
            let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: self.endDate, options: [])
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    self.errorLabel.setHidden(false)
                    self.errorLabel.setText(error.debugDescription)
                    return
                }
                
                if let result = tmpResult {
                    self.setupTable(result: result)
                    self.requestSleepTrack(result: result)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    func setupTable(result:[HKSample]) {
        resultTable.setNumberOfRows(result.count, withRowType: "SleepRow")
        
        for (i,item) in result.enumerated() {
            if let sample = item as? HKCategorySample {
                              
                if let row = resultTable.rowController(at: i) as? SleepRow {
                    var value = "Unknow"
                    switch sample.value {
                    case HKCategoryValueSleepAnalysis.inBed.rawValue:
                        value = "InBed"
                    case HKCategoryValueSleepAnalysis.asleep.rawValue:
                        value = "Asleep"
                    case HKCategoryValueSleepAnalysis.awake.rawValue:
                        value = "Awake"
                    default:
                        value = "Unknow"
                    }

                    row.titleLabel.setText(value)
                    
                    row.startLabel.setText("Start : \(sample.startDate.toCurrentTimeZoneString())")
                    row.endLabel.setText("End : \(sample.endDate.toCurrentTimeZoneString())")
                }
            }
        }
    }
    
    func requestSleepTrack(result:[HKSample]) {
        
        apiNetwork = Network(host: WatchKitConnection.shared.host)
        
        for (i,item) in result.enumerated() {
            if let sample = item as? HKCategorySample {
                              
                if let row = resultTable.rowController(at: i) as? SleepRow {
                    var value = "Unknow"
                    switch sample.value {
                    case HKCategoryValueSleepAnalysis.inBed.rawValue:
                        value = "InBed"
                    case HKCategoryValueSleepAnalysis.asleep.rawValue:
                        value = "Asleep"
                    case HKCategoryValueSleepAnalysis.awake.rawValue:
                        value = "Awake"
                    default:
                        value = "Unknow"
                    }
                    row.titleLabel.setText(value)
                    
                    row.startLabel.setText("Start : \(sample.startDate.toCurrentTimeZoneString())")
                    row.endLabel.setText("End : \(sample.endDate.toCurrentTimeZoneString())")
            
                    let track :[String:Any] = ["userId": UUIDGenerator.sharedInstance.string,
                                               "type": encrypt(value),
                                               "start": encrypt("\(sample.startDate.toCurrentTimeZoneString())"),
                                               "end": encrypt("\(sample.endDate.toCurrentTimeZoneString())")]
                        
                    self.postSleepTrack(param: track)
                }
            }
        }
    }
    
    func encrypt(_ string:String) -> String {               // 16 bytes for AES128
        let aes256 = AES(key: Constant.KEY256, iv: Constant.IV)
        let encryptedPassword256 = aes256?.encrypt(string: string)

        return encryptedPassword256?.base64EncodedString() ?? ""
    }
    
    func postSleepTrack(param: [String:Any]) {
        
        self.apiNetwork.post(path: "/sleep/track", params: param ){ (data, error) in
            
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
