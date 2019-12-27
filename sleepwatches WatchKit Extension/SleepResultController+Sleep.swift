//
//  InterfaceController + Health.swift
//  tracking WatchKit Extension
//
//  Created by pongsil vachirajongkol on 16/11/2562 BE.
//  Copyright © 2562 timecapsule. All rights reserved.
//

import HealthKit

extension SleepResultController {
    
    func setupTrackingSleep() {
        errorLabel.setHidden(true)
        let types = Set([HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
        
        healthStore.requestAuthorization(toShare: types, read: types) { (success, error) in
            guard success == true else {
                return
            }
            
            self.saveSleepAnalysis()
        }
    }
    
    func saveSleepAnalysis() {

        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            let inBed = HKCategorySample(type: sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: self.startDate, end: self.endDate)
            healthStore.save(inBed) { (success, error) in
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            let asleep = HKCategorySample(type: sleepType, value: HKCategoryValueSleepAnalysis.asleep.rawValue, start: self.startDate, end: self.endDate)
            healthStore.save(asleep) { (success, error) in
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            let awake = HKCategorySample(type: sleepType, value: HKCategoryValueSleepAnalysis.awake.rawValue, start: self.startDate, end: self.endDate)
            healthStore.save(awake) { (success, error) in
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                self.retrieveSleepAnalysis()
            }
        }
    }
    
    func retrieveSleepAnalysis() {
        
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            
            let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: self.endDate, options: [])
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 10000, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
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
                    let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                    row.titleLabel.setText(value)
                    
                    row.startLabel.setText("Start : \(sample.startDate.toCurrentTimeZoneString())")
                    row.endLabel.setText("End : \(sample.endDate.toCurrentTimeZoneString())")
                }
            }
        }
    }
    
    func encrypt(_ string:String) -> String {               // 16 bytes for AES128
        let aes256 = AES(key: Constant.KEY256, iv: Constant.IV)
        let encryptedPassword256 = aes256?.encrypt(string: string)

        return encryptedPassword256?.base64EncodedString() ?? ""
    }
    
    func requestSleepTrack(result:[HKSample]) {
        
        for (i,item) in result.enumerated() {
            if let sample = item as? HKCategorySample {
                              
                if let row = resultTable.rowController(at: i) as? SleepRow {
                    let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                    row.titleLabel.setText(value)
                    
                    row.startLabel.setText("Start : \(sample.startDate.toCurrentTimeZoneString())")
                    row.endLabel.setText("End : \(sample.endDate.toCurrentTimeZoneString())")
                    
                    let track :[String:Any] = ["id": UUIDGenerator.sharedInstance.string,
                                               "type": encrypt(value),
                                               "start": encrypt("\(sample.startDate.toCurrentTimeZoneString())"),
                                               "end": encrypt("\(sample.endDate.toCurrentTimeZoneString())")]
                        
                    self.postSleepTrack(param: track)
                }
            }
        }
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
