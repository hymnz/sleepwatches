//
//  NSURLRequest+Certificate.swift
//  sleepwatches
//

import Foundation

extension NSURLRequest {
    static func allowsAnyHTTPSCertificate(forHost host: String) -> Bool {
        return true
    }
}
