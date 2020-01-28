//
//  UUIDGenerator.swift
//  sleepwatches WatchKit Extension
//
//  Created by pongsil vachirajongkol on 10/12/2562 BE.
//

import Foundation

class UUIDGenerator: NSObject {
    static var sharedInstance = UUIDGenerator()
    
    var string: String
    
    private override init() {
        
        if let uuid = UserDefaults.standard.object(forKey: "UUIDKey") as? String {
            string = uuid
        } else {
            string = UUID().uuidString
            UserDefaults.standard.set(string, forKey: "UUIDKey")
            UserDefaults.standard.synchronize()
        }
    }
}
