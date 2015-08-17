//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by George McMullen on 8/5/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import Foundation

extension ParseClient {
    
    // Constants
    struct Constants {
        
        // URLs
        static let StudentLocation : String = "https://api.parse.com/1/classes/StudentLocation"
        // GUIDs
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        // Options
        static let Options = "?limit=100&order=-updatedAt"
    }
    
    // JSON Body Keys
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let Firstname = "firstName"
        static let Lastname = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
}