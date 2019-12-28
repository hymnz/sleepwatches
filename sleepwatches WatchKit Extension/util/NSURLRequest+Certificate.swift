//
//  NSURLRequest+Certificate.swift
//  StreamingFund
//
//  Created by Supakit Thanadittagorn on 3/14/17.
//  Copyright © 2017 Settrade. All rights reserved.
//

import Foundation

extension NSURLRequest {
    static func allowsAnyHTTPSCertificate(forHost host: String) -> Bool {
        return true
    }
}
