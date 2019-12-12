//
//  NetworkResponse.swift
//  sleepwatches WatchKit Extension
//
//  Created by pongsil vachirajongkol on 10/12/2562 BE.
//

import Foundation

struct NetworkResponse: Equatable {
    let data: Data?
    let response: URLResponse?

    func jsonObject<T>(with options: JSONSerialization.ReadingOptions = []) -> (T?, NetworkError?) {
        if let r = response as? HTTPURLResponse {
            do {
                guard let data = data else {
                    return (nil, JSONError.noData(statusCode: r.statusCode).networkError)
                }

                let dataDict = try JSONSerialization.jsonObject(with: data, options: options) as? T
                return (dataDict, nil)
            } catch {
                if let data = data, let decodeData = String(data: data, encoding: .utf8) {
                    print("Error : " + decodeData)
                    return (nil, NetworkError(code: "", message: "Error: System error! Pls try again."))
                }
                return (nil, JSONError.cannotConvert(statusCode: r.statusCode).networkError)
            }
        } else {
            return (nil, JSONError.noResponse.networkError)
        }
    }
}

func ==(lhs: NetworkResponse, rhs: NetworkResponse) -> Bool {
    return lhs.data == rhs.data && lhs.response == rhs.response
}
