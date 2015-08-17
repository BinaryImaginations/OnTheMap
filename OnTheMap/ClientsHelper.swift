//
//  ClientsHelper.swift
//  OnTheMap
//
//  Created by George McMullen on 8/11/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit


/// Share between all clients
class ClientsHelper:  NSObject {
    
    // Session object
    var session: NSURLSession

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Build the HTTP body
    func getHTTPBody(header: String?, parameters: [String : AnyObject], innerBrackets: Bool) -> String {
        var urlVals = [String]()
        // Add the value pair to the body string
        for (key, value) in parameters {
            let stringValue = "\(value)"
            urlVals += ["\"" + key + "\": \"" + "\(stringValue)" + "\""]
        }
        var stringStart, stringEnd : String
        stringEnd = (innerBrackets ? "}" : "") + "}"
        if header == nil {
            stringStart = "{" + (innerBrackets ? "{" : "")
        } else {
            stringStart = "{" + (header!) + (innerBrackets ? "{" : "")
        }

        // Setup the opening and closing inner bracket (if needed)
        return stringStart + joinCustom(parameters) + stringEnd
    }
   
    // Simple custom join that only puts quotes around passed strings.  Each individual type could be called out for specific control
    func joinCustom(parameters: [String : AnyObject]) -> String {
        // Variable to hold the value pairs
        var urlVars = String()
        for (key, value) in parameters {
            // If the variable isn't empty, add a seperator
            if !urlVars.isEmpty {
                urlVars = urlVars + ","
            }
            // If this is a string type
            if value is String {
                // String, add quotes
                urlVars = urlVars + "\"\(key)\": \"\(value)\""
            } else {
                // Not a string so just use the value
                urlVars = urlVars + "\"\(key)\": \(value.description)"
            }
        }
        // Return the value pair
        return urlVars
    }
}