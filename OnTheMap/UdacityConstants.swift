//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by George McMullen on 7/31/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // Constants
    struct Constants {
        
        // URLs
        static let BaseURL : String = "http://www.udacity.com/api/"
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
        static let AuthorizationURL : String = "https://www.udacity.com/api/session"
        // Misc
        static let SecurityBytes: Int = 5  // Number of bytes to skip at start of JSON response
    }
    
    // Methods
    struct Methods {
        static let UserInformation : String = "https://www.udacity.com/api/users/"
    }
    
    // JSON Body Keys
    struct JSONBodyKeys {
        static let header = "\"udacity\":"
        
        static let Username = "username"
        static let Password = "password"
    }
    
    // JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
    }
}