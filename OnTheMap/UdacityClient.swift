//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by George McMullen on 7/30/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit
import Foundation

class UdacityClient : ClientsHelper {

    var key : String? = nil
    var sessionID : String? = nil

    // User Data
    var firstName : String? = nil
    var lastName : String? = nil

    // User Authentication
    func authenticateWithViewController(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Make sure that we have a username and password (before we do expensive network check)
        if username.isEmpty || password.isEmpty {
            completionHandler(success: false, errorString: "Please enter in a username and password.")
            return
        }
        // Setup the json body parameter list
        let jsonBody : [String:AnyObject] = [
            JSONBodyKeys.Username: username as String,
            JSONBodyKeys.Password: password as String
        ]
        // Use a post task to validate login
        let task = getPostTask(Constants.AuthorizationURL, jsonBody: jsonBody) { data, error in
            // If an error was returned, display returned error message
            if error != nil {
                completionHandler(success: false, errorString: error!.description)
                return
            }
            //
            // Successful login:
            //
            // Parse the data to get the session ID and key
            if !self.parseUserSessionData(data) {
                // Unable to parse user session data - email or password was incorrect
                completionHandler(success: false, errorString: "The email or password was not valid.")
                return
            }
            // Get the user information
            self.taskForGetUserData() {success, error in
                // Return the success or failure (with error message)
                completionHandler(success: success!, errorString: error?.description)
                return
            }
        }
        task.resume()
    }

    // Post method - login
    // NOTE:  Most of the code is directly from the Udacity API document
    func getPostTask(urlString: String, jsonBody: [String:AnyObject], completionHandler: (result: NSData!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        // Create the URL request from the passed url string
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        // Add the post and header values
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Generate the body using the passed json body
        request.HTTPBody = getHTTPBody(JSONBodyKeys.header, parameters: jsonBody, innerBrackets: true).dataUsingEncoding(NSUTF8StringEncoding)
        // Generate the task from the request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(result: nil, error: error)
                return
            }
            // Return the shifted data (remove the security prefix)
            completionHandler(result: data.subdataWithRange(NSMakeRange(Constants.SecurityBytes, data.length - Constants.SecurityBytes)), error: nil)
        }
        // Start the task
        task.resume()
        return task
    }
    
    // Parse the JSON user data for the session ID and key
    func parseUserSessionData(data: NSData) -> Bool {
        // Parse the user session data
        if let userData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as? NSDictionary,
            let accountvalue = userData["account"] as? [String: AnyObject],
            let sessionvalue = userData["session"] as? [String: String]
        {
            // Set the key and session ID
            self.key = accountvalue["key"] as? String
            self.sessionID = sessionvalue["id"]!
            return true
        }
        return false
    }
    
    // Get the user data (first name, last name, etc.)
    func taskForGetUserData(completionHandler: (success: Bool?, error: NSError?) ->  Void) -> NSURLSessionTask {
        // Build the request
        let request = NSMutableURLRequest(URL: NSURL(string: Methods.UserInformation + "\(self.key!)")!)
        // Generate the task for the request
        let task = session.dataTaskWithRequest(request) {data, response, error in
            // If we have an error, return the error message
            if error != nil  {
                completionHandler(success: false, error: error)
            }
            // Shifted data (remove the security prefix)
            let newData = data.subdataWithRange(NSMakeRange(Constants.SecurityBytes, data.length - Constants.SecurityBytes))
            if let userData = NSJSONSerialization.JSONObjectWithData(newData, options: .MutableContainers, error: nil) as? NSDictionary,
                let user = userData["user"] as? [String: AnyObject],
                firstName = user["first_name"] as? String,
                lastName = user["last_name"] as? String
            {
                // Store the users name
                self.firstName = firstName
                self.lastName = lastName
                // Return successful
                completionHandler(success: true, error: nil)
            }
        }
        task.resume()
        return task
    }

    // Get the user data (first name, last name, etc.)
    func taskForGetPublicUserData(completionHandler: (success: Bool?, error: NSError?) ->  Void) -> NSURLSessionTask {
        // Build the request
        let request = NSMutableURLRequest(URL: NSURL(string: Methods.UserInformation + "\(self.key!)")!)
        // Generate the task for the request
        let task = session.dataTaskWithRequest(request) {data, response, error in
            // If we have an error, return the error message
            if error != nil  {
                completionHandler(success: false, error: error)
            }
            // Shifted data (remove the security prefix)
            let newData = data.subdataWithRange(NSMakeRange(Constants.SecurityBytes, data.length - Constants.SecurityBytes))
            if let userData = NSJSONSerialization.JSONObjectWithData(newData, options: .MutableContainers, error: nil) as? NSDictionary,
                let user = userData["user"] as? [String: AnyObject],
                firstName = user["first_name"] as? String,
                lastName = user["last_name"] as? String
            {
                // Store the users name
                self.firstName = firstName
                self.lastName = lastName
                // Return successful
                completionHandler(success: true, error: nil)
            }
        }
        task.resume()
        return task
    }

    // Logout
    // NOTE:  Most of the code is directly from the Udacity API document
    func logOut(didComplete: (success: Bool) -> Void) {
        // Build the request
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.AuthorizationURL)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        // Generate the task for the request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            // If we have an error, return false
            if error != nil {
                didComplete(success: false)
                return
            }
            // Return the shifted data (remove the security prefix)
            let newData = data.subdataWithRange(NSMakeRange(Constants.SecurityBytes, data.length - Constants.SecurityBytes))
            didComplete(success: true)
        }
        task.resume()
    }

    //
    // Singleton:  return the instance or create a new one
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}