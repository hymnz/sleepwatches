//
//  JsonError.swift
//  sleepwatches WatchKit Extension
//
//  Created by pongsil vachirajongkol on 10/12/2562 BE.
//

import Foundation

enum JSONError: Error {
    case noData(statusCode: Int)
    case noResponse
    case cannotConvert(statusCode: Int)
    case formatNotMatch(for: String)
    case invalidObject

    var networkError: NetworkError {
        switch self {
        case .noData(let statusCode):
            return NetworkError(code: "", message: "Error no message with status code: \(statusCode)")
        case .noResponse:
            return NetworkError(code: "", message: "Error no response data")
        case .cannotConvert(let statusCode):
            return NetworkError(code: "", message: "Error cannot convert respond data with status code: \(statusCode)")
        case .formatNotMatch( _):
            return NetworkError(code: "", message: "Error format not match")
        case .invalidObject:
            return NetworkError(code: "", message: "Error invalid json object")
        }
    }
}
