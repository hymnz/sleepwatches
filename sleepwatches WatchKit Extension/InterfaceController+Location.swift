//
//  InterfaceController + Health.swift
//  tracking WatchKit Extension
//
//  Created by pongsil vachirajongkol on 16/11/2562 BE.
//  Copyright © 2562 timecapsule. All rights reserved.
//

import CoreLocation

extension InterfaceController: CLLocationManagerDelegate{
    
    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.requestLocation()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
//        self.altitudeLabel.setText("-")
        self.speedLabel.setText("-")
        self.gpsLabel.setText("-")
        self.speed = ""
        self.latitude = ""
        self.longitude = ""
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
//        let altitude = location.altitude.roundToDecimal(2)
//        altitudeLabel.setText("\(Int(altitude))m")
        
        gpsLabel.setText("\(location.coordinate.latitude.roundToDecimal(4)),\(location.coordinate.longitude.roundToDecimal(4))")
        latitude = "\(location.coordinate.latitude.roundToDecimal(4))"
        longitude = "\(location.coordinate.longitude.roundToDecimal(4))"
        
        if location.speed >= 0 {
            speedLabel.setText("\((location.speed * 3.6 ).roundToDecimal(2))")
            speed = "\((location.speed * 3.6 ).roundToDecimal(2))"
        }
        else {
            speedLabel.setText("-")
            speed = ""
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
