//
//  MapViewController.swift
//  OnTheMap
//
//  Created by George McMullen on 8/7/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: ControllerHelper, MKMapViewDelegate {
    
    // Link to map view object
    @IBOutlet weak var mapView: MKMapView!
    
    // View loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegate to this class
        mapView.delegate = self
    }
    
    // View is about to show
    override func viewWillAppear(animated: Bool) {
        // Load annotations
        self.loadAnnotations()
    }
    
    @IBAction func pinPressed(sender: AnyObject) {
        // Create a new controller to our add pin controller
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AddPinViewController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // Populate the annotations
    func loadAnnotations() {
        var annotations = [MKPointAnnotation]()
        
        // Remove all of the annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Load the map pin locations into the map view
        for student in ParseClient.sharedInstance().students {
            // Load the map pin as the annotation
            annotations.append(student.mapPin)
        }
        // Load all of the annotations at once
        mapView.addAnnotations(annotations)
    }
    
    // MapView
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // Draw the annotation
        let reuseID = "Pin"
        
        if let annotation = annotation as? MKPointAnnotation {
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            }
            return view
        }
        return nil
    }
 
    // User touched an annotation
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // If user touched an annotation
        if control == annotationView.rightCalloutAccessoryView {
            // Open the URL
            UIApplication.sharedApplication().openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }

    // Logout button pressed
    @IBAction func logoutButton(sender: AnyObject) {
        // Logout of Udacity
        UdacityClient.sharedInstance().logOut() { (complete) in
            if !complete {
                println("Logout failure")
            }
        }
        // Dismiss the view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
}
