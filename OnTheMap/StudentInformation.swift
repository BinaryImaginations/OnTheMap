//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by George McMullen on 8/6/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import Foundation
import MapKit

class StudentInformation : NSObject {
    var firstName : String
    var lastName : String
    var mediaURL : String
    var latitude : Double
    var longitude : Double
    
    var mapPin : MKPointAnnotation
    
    init(data: NSDictionary) {
        // Student information
        firstName = data["firstName"] as! String
        lastName = data["lastName"] as! String
        mediaURL = data["mediaURL"] as! String
        latitude = data["latitude"] as! Double
        longitude = data["longitude"] as! Double
        // Store the map pin information
        mapPin = MKPointAnnotation()
        mapPin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapPin.title = "\(firstName) \(lastName)"
        mapPin.subtitle = mediaURL
    
        super.init()
    }
    
    // Create a method to print out the student information for debugging.
    func customdescription() -> String {
        return "\(firstName) \(lastName): [\(latitude)][\(longitude)]->\"\(mediaURL)\""
    }
    override var description : String {
        return customdescription()
    }
}