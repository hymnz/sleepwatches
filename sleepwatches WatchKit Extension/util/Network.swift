//
//  Network.swift
//  sleepwatches WatchKit Extension
//
//  Created by pongsil vachirajongkol on 10/12/2562 BE.
//

import Foundation

protocol NetworkParameter {

}
extension Dictionary : NetworkParameter {
    
}
extension Array : NetworkParameter {
    
}

class Network: NSObject, URLSessionDelegate{
    var allowInvalidCertificate = true
    var host: String
    var session: URLSession!
    var queue: OperationQueue?

    init(host: String) {
        self.host = host
        super.init()
        self.queue = OperationQueue()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: self.queue)
    }

    func post(path: String, params: NetworkParameter,dispatchGroup: DispatchGroup? = nil, completion: @escaping (NetworkResponse?, NetworkError?) -> Void) {
        guard let convertedURL = URL(string: host + path) else {
            completion(nil, parseURLNetworkError(for: path))
            return
        }
        if !JSONSerialization.isValidJSONObject(params) {
            completion(nil, JSONError.invalidObject.networkError)
            return
        }

        var request = URLRequest(url: convertedURL)
        request.cachePolicy = .reloadIgnoringCacheData
        
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        dataTask(with: request,dispatchGroup: dispatchGroup, completion: completion)
    }

    private func parseURLNetworkError(for url: String) -> NetworkError {
        return NetworkError(code: "", message: "Cannot parse url with path: \(url)")
    }
    
    func dataTask(with request: URLRequest, dispatchGroup:DispatchGroup? = nil, completion: @escaping (NetworkResponse?, NetworkError?) -> Void) {
        dispatchGroup?.enter()
        let task = session.dataTask(with: request) {
            data, response, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                        dispatchGroup?.leave()
                        return
                    }
                    completion(nil, NetworkError(code: "", message: error.localizedDescription))
                    dispatchGroup?.leave()
                    return
                }
                if let r = response as? HTTPURLResponse {
                    if r.statusCode >= 400 {
                        let networkResponse = NetworkResponse(data: data, response: response)
                        let json:(data: Dictionary<String, Any>?, error: NetworkError?) = networkResponse.jsonObject()

                        if let networkError = json.error {
                            completion(nil, networkError)
                            dispatchGroup?.leave()
                            return
                        }

                        if let error = json.data?["error"] as? Dictionary<String, Any>,
                            let code = error["code"] as? String,
                            let message = error["message"] as? String {
                            completion(nil, NetworkError(code: code, message: message))
                        }
                        else if let code = json.data?["code"] as? String, let message = json.data?["message"] as? String {
                            completion(nil, NetworkError(code: code, message: message))
                        }
                        else {
                            completion(nil, JSONError.formatNotMatch(for: String(data: data!, encoding: .utf8)!).networkError)
                        }
                    } else {

                        completion(NetworkResponse(data: data, response: response) , nil)
                    }
                } else {
                    completion(nil, JSONError.noResponse.networkError)
                }
                dispatchGroup?.leave()
            }
        }
        task.resume()
    }
    
    // MARK: - Delegate

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if allowInvalidCertificate {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
