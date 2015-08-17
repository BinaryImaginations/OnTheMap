//
//  ControllerHelper.swift
//  OnTheMap
//
//  Created by George McMullen on 8/10/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit
import MapKit

/// Share between all controllers
class ControllerHelper: UIViewController {

    // Use a custom UIAlertAction popup to display our message
    func showAlert(title: String, message: String) {
        // Create the controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        // Get an OK action
        let OkAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        // Add it to the controller
        alertController.addAction(OkAction)
        // Present the new controller
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Validate that the passed string is a URL (see if we can open it)
    func validURL (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    // Center the map based upon the passed location
    func centerMapOnLocation(mapView: MKMapView, location: CLLocation, distance: CLLocationDirection = 200000) {
        // Get the region
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, distance, distance)
        // Move to the region
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

    