//
//  InterfaceController + Health.swift
//  tracking WatchKit Extension
//
//  Created by pongsil vachirajongkol on 16/11/2562 BE.
//  Copyright © 2562 timecapsule. All rights reserved.
//

import HealthKit

extension InterfaceController{
    
    func startTrackingHeartRate() {
        heartRateLabel.setText("-")
        heartRate = ""
        guard HKHealthStore.isHealthDataAvailable() == true else { //err checking/handling
            return
        }
        
        let types = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        
        healthStore.requestAuthorization(toShare: types, read: types) { (success, error) in
            guard success == true else {
                return
            }
            self.beginWorkout()
        }
    }
    
    func beginWorkout() {
        let  configure = HKWorkoutConfiguration()
        configure.activityType = .other
        
        do {
          self.workoutSession = try HKWorkoutSession(configuration: configure)
        } catch let error {
            print(error)
          return
        }
        
        let sampleType =
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        
        let query = HKObserverQuery(sampleType: sampleType!, predicate: nil) {
            query, completionHandler, error in
            
            self.fetchLatestHeartRateSample(completion: { sample in
              guard let sample = sample else {
                return
              }
              DispatchQueue.main.async {
                let heartRateUnit = HKUnit(from: "count/min")
                let heartRate = sample
                  .quantity
                  .doubleValue(for: heartRateUnit)

                self.heartRateLabel.setText("\(Int(heartRate))")
                self.heartRate = "\(Int(heartRate))"
              }
            })
        }
         
        healthStore.execute(query)
    }
    
    public func fetchLatestHeartRateSample(
      completion: @escaping (_ sample: HKQuantitySample?) -> Void) {

        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completion(nil)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                    end: Date(),
                                                    options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)

        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                    
                                    guard error == nil else {
                                        print("Error: \(error!.localizedDescription)")
                                        return
                                        
                                    }
                                    
                                    if let result = results, result.count > 0 {
                                        completion(results?[0] as? HKQuantitySample)
                                    }
                                    else {
                                        completion(nil)
                                    }
                                    
        }

        self.healthStore.execute(query)
    }
}
