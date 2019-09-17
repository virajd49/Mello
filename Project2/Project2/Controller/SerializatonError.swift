//
//  SerializatonError.swift
//  Project2
//
//  Created by virdeshp on 5/10/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import Foundation


enum SerializationError: Error {
    
    /// This case indicates that the expected field in the JSON object is not found.
    case missing(String)
}
