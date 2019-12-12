//
//  NetworkError.swift
//  sleepwatches WatchKit Extension
//
//  Created by pongsil vachirajongkol on 10/12/2562 BE.
//

import Foundation

struct NetworkError: Equatable, Error {
    var code: String
    var message: String
}

func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
    return lhs.code == rhs.code && lhs.message == rhs.message
}
