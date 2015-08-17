//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by George McMullen on 8/12/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: ControllerHelper, MKMapViewDelegate, UITextFieldDelegate {
    let URLMessageText : String = "Enter a URL..."
    let SubmitButtonText : String = "Submit"
    let SubmitButtonPressedText : String = "Process..."
    
    // Location view
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locateOnTheMapButton: UIButton!
    // Map view
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mkMapView: MKMapView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    // Universal cancel button
    @IBOutlet weak var cancelButton: UIButton!
    // Temp variables to hold entered values
    var enteredLocation: CLLocation?
    var enteredString: String = ""
    
    // Loaded in memory
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show the location view and hide the map view
        mapView.hidden = true
        locationView.hidden = false
        // Set self as the delegates
        mkMapView.delegate = self
        locationTextField.delegate = self
        urlTextField.delegate = self
        // Set the text on the submit button
        submitButton.setTitle(SubmitButtonText, forState: .Normal)
    }
    
    // Cancel button
    @IBAction func cancledPressed(sender: AnyObject) {
        // Dismiss view controller and return to previous one
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Locate button pressed
    @IBAction func locatePressed(sender: AnyObject) {
        // If users entered in a location
        if !locationTextField.text.isEmpty {
            // Start the loading icon animation
            startLoading()
            // Geocode the entered text string
            var geocoder = CLGeocoder()
            // Start geocoder
            geocoder.geocodeAddressString(locationTextField.text, completionHandler: geocodingComplete)
        }
    }
    
    // Submit button pressed
    @IBAction func submitPressed(sender: UIButton) {
        submitButton.setTitle(SubmitButtonPressedText, forState: .Normal)
        // If we have a URL and a location
        if !urlTextField.text.isEmpty && enteredLocation != nil {
            // Fix any backslashes that the user might have entered
            let url = urlTextField.text.stringByReplacingOccurrencesOfString("\\", withString: "/")
            // Post the new location
            ParseClient.sharedInstance().postNewLocation(enteredLocation!.coordinate.latitude, longitude: enteredLocation!.coordinate.longitude, mediaURL: url, mapString: enteredString) { success, errorString in
                // If we are successful, then update the locations (pins) on the map by reading in the new values.  If we fail,
                // display an error and then close the view controller
                if !success {
                    self.submitButton.setTitle(self.SubmitButtonText, forState: .Normal)
                    // Show error message
                    self.showAlert("Posting Error", message: errorString!)
                } else {
                    // Create/open the parse client object and get the student locations
                    ParseClient.sharedInstance().getStudentLocation() { (success, errorString) in
                        if !success {
                            // Failure:  Display the error message returned from the authentication routine
                            dispatch_async(dispatch_get_main_queue(), {
                                self.showAlert("Data Read Error", message: errorString!)
                            })
                        }
                    }
                }
                // Dismiss the view controller
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // Geocoding completed
    func geocodingComplete(placemarks: [AnyObject]!, error: NSError!) {
        // Stop the loading icon animation
        stopLoading()
        
        // If we didn't get an error
        if error == nil && placemarks.count > 0 {
            // Show the map view
            locationView.hidden = true
            mapView.hidden = false
            // Set default URL text
            urlTextField.text = URLMessageText
            
            // Get the geocoded location
            let placemark = placemarks[0] as! CLPlacemark
            let location = placemark.location!
            
            // Build the map pin from the student information
            let mapPin = MKPointAnnotation()
            mapPin.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            mapPin.title = "\(UdacityClient.sharedInstance().firstName!) \(UdacityClient.sharedInstance().lastName!)"
            mapPin.subtitle = ""
            // Add the map pin (no URL yet)
            mkMapView.addAnnotation(mapPin)
            // Save the values
            enteredString = locationTextField.text
            enteredLocation = location
            // Center the map on the location
            centerMapOnLocation(mkMapView, location: location, distance: 200000)
        } else {
            // Show error message
            showAlert("Error Geocoding", message: "Unable to Geocode the entered value")
        }
    }
    
    // Start loading graphic
    func startLoading() {
        indicator.startAnimating()
        locationView.alpha = 0.5
    }
    
    // End loading graphic
    func stopLoading() {
        indicator.stopAnimating()
        locationView.alpha = 1
    }
    
    // Allow user to press enter to leave editing
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Resign the text field that is currently being edited
        textField.resignFirstResponder()
        return true
    }
}
