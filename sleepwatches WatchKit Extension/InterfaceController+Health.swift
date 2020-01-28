//
//  InterfaceController + Health.swift
//  tracking WatchKit Extension
//
//  Created by pongsil vachirajongkol on 16/11/2562 BE.
//  Copyright © 2562 timecapsule. All rights reserved.
//

import HealthKit

extension InterfaceController: HKLiveWorkoutBuilderDelegate{
    
    func startTrackingHeartRate() {
        heartRateLabel.setText("-")
        heartRate = nil
        guard HKHealthStore.isHealthDataAvailable() == true else { //err checking/handling
            return
        }
        
        let types = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,HKSampleType.workoutType()])
        
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
            self.workoutSession = try HKWorkoutSession(healthStore: self.healthStore, configuration: configure)
            self.builder = workoutSession?.associatedWorkoutBuilder()
            
            self.builder?.delegate = self
            
            self.builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configure)
            
            self.workoutSession?.startActivity(with: Date())
            self.builder?.beginCollection(withStart: Date()) { (success, error) in
                print(success)
                if let error = error {
                    print(error)
                }
            }
        } catch let error {
            print(error)
          return
        }
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        print("GET DATA: \(Date())")
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }
            
            if let statistics = workoutBuilder.statistics(for: quantityType) {
                handleSendStatisticsData(statistics)
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }

    private func handleSendStatisticsData(_ statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
            self.heartRate = Double( round( 1 * value! ) / 1 )
            
        default:
            return
        }
    }
}
