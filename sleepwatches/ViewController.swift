//
//  ViewController.swift
//  sleepwatches
//
//  Created by pongsil vachirajongkol on 20/1/2563 BE.
//  Copyright © 2563 pongsil vachirajongkol. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WatchKitConnectionDelegate, UITextFieldDelegate {

    @IBOutlet weak var hrLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lngLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var acceleroLabel: UILabel!
    @IBOutlet weak var gyroLabel: UILabel!
    
    @IBOutlet weak var syncStatusLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var hostTextField: UITextField!
    
    var apiNetwork : Network!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hostTextField.text = Constant.HOST
        self.apiNetwork = Network(host: "https://\(Constant.HOST)")
        self.syncStatusLabel.text = "Apple Watch is Not Sync"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        WatchKitConnection.shared.delegate = self
    }
    
    @IBAction func segmentDidChanged(_ sender: Any) {
        self.syncStatusLabel.text = "Apple Watch is Not Sync"
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.syncStatusLabel.text = "Apple Watch is Not Sync"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func encrypt(_ string:String) -> String {               // 16 bytes for AES128
        let aes256 = AES(key: Constant.KEY256, iv: Constant.IV)
        let encryptedPassword256 = aes256?.encrypt(string: string)

        return encryptedPassword256?.base64EncodedString() ?? ""
    }
    
    func didReceiveMessageSync() {
        self.syncStatusLabel.text = "Sync Complete"
    }
    
    func didReceiveMessageTrack(_ trackData: [String:Any]) {
        
        var trackEncrypt :[String:Any] = [:]
        
        if let hr = trackData["hr"] as? Double {
            self.hrLabel.text = String(hr)
            trackEncrypt["hr"] = encrypt(String(hr))
        }
        if let geo = trackData["geo"] as? [String:Any],
            let lat = geo["lat"] as? Double,
            let lng = geo["long"] as? Double{
            self.latLabel.text = String(lat)
            self.lngLabel.text = String(lng)
            trackEncrypt["geo"] = ["lat":encrypt(String(lat)),"long":encrypt(String(lng))]
        }
        if let speed = trackData["speed"] as? Double {
            self.speedLabel.text = String(speed)
            trackEncrypt["speed"] = encrypt(String(speed))
        }
        
        if let altitude = trackData["altitude"] as? Int {
            self.altitudeLabel.text = String(altitude)
            trackEncrypt["altitude"] = encrypt(String(altitude))
        }
        if let accelero = trackData["acc"] as? [String:Any],
            let x = accelero["x"] as? Double,
            let y = accelero["y"] as? Double,
            let z = accelero["z"] as? Double {
            self.acceleroLabel.text = "x: \(x),\n y: \(y),\n z: \(z)"
            trackEncrypt["acc"] = ["x":encrypt(String(x)),"y":encrypt(String(y)),"z":encrypt(String(z))]
        }
        if let gyro = trackData["gyr"] as? [String:Any],
            let x = gyro["x"] as? Double,
            let y = gyro["y"] as? Double,
            let z = gyro["z"] as? Double {
            self.gyroLabel.text = "x: \(x),\n y: \(y),\n z: \(z)"
            trackEncrypt["gyr"] = ["x":encrypt(String(x)),"y":encrypt(String(y)),"z":encrypt(String(z))]
        }
        
        var param :[String:Any] = ["userId": UUIDGenerator.sharedInstance.string]
        param["ts"] = Date().timeIntervalSince1970
        param["payload"] = trackEncrypt
        
        print(param)
        
        apiNetwork.post(path: "/api/v1/apple/watches", params: param ){ (data, error) in
        
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
    
    @IBAction func saveAction(_ sender: Any) {
        
        if let host = self.hostTextField.text,
            let interval = self.segmentControl.titleForSegment(at: self.segmentControl.selectedSegmentIndex) {
            self.apiNetwork = Network(host: "https://\(host)")
            WatchKitConnection.shared.sendMessage(message: ["host" : host as AnyObject,"uuid" : UUIDGenerator.sharedInstance.string as AnyObject, "interval" : interval as AnyObject])
        }
    }
}

