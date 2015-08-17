//
//  ParseClient.swift
//  OnTheMap
//
//  Created by George McMullen on 8/5/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class ParseClient : ClientsHelper {

    // Arraw to hold list of students
    var students : [StudentInformation] = []
    
    override init() {
        // Initiate students array
        students = []
        super.init()
    }
    
    // Method to get student location information
    func getStudentLocation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        // Create the URL request from the passed url string
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.StudentLocation)\(Constants.Options)")!)
        // Add App ID and API key to the request
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        // Generate the task from the request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            // If an error was returned, display returned error message
            if error != nil {
                completionHandler(success: false, errorString: error!.description)
                return
            }
            // Parse the location information from the JSON data
            self.parseLocationData(data) {success, error in
                // Return the success and error (if any)
                completionHandler(success: success, errorString: error)
            }
        }
        // Start the task
        task.resume()
    }
    
    // Parse the JSON student data
    func parseLocationData(data: NSData, completionHandler: (success: Bool, errorString: String?) -> Void) {
        // Clear out the array
        students.removeAll()
        // Get the users JSON data
        if let usersData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as? NSDictionary {
            if let studentsData = usersData["results"] as? [NSDictionary] {
                // Step through the users data
                for student in studentsData {
                    // Create a student informaiton object
                    students.append(StudentInformation(data: student))
                }
            } else {
                // Error getting the dictionary from JSON data
                completionHandler(success: false, errorString: "Unable to locate results in JSON data")
                return
            }
        }
        // Return successful
        completionHandler(success: true, errorString: nil)
    }
    
    // Post new location data
    func postNewLocation(latitude: Double, longitude: Double, mediaURL: String, mapString: String, completionHandler: (success: Bool, errorString: String?) -> Void) -> Void {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.StudentLocation)")!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Setup the json body parameter list
        let jsonBody : [String:AnyObject] = [
            JSONBodyKeys.UniqueKey: UdacityClient.sharedInstance().key as String!,
            JSONBodyKeys.Firstname: UdacityClient.sharedInstance().firstName as String!,
            JSONBodyKeys.Lastname: UdacityClient.sharedInstance().lastName as String!,
            JSONBodyKeys.MapString: mapString as String!,
            JSONBodyKeys.MediaURL: mediaURL as String!,
            JSONBodyKeys.Latitude: latitude as Double,
            JSONBodyKeys.Longitude: longitude as Double
        ]
        // Generate the body using the passed json body
        request.HTTPBody = getHTTPBody(nil, parameters: jsonBody, innerBrackets: false).dataUsingEncoding(NSUTF8StringEncoding)
        // Generate the task from the request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, errorString: error!.description)
                return
            }
            // Reload the student list
            self.getStudentLocation() { (success, errorString) in
                completionHandler(success: success, errorString: errorString)
            }
        }
        // Start the task
        task.resume()
    }
        
    //
    // Singleton:  return the instance or create a new one
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}