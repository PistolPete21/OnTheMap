//
//  Udacity.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/27/21.
//

import Foundation

struct Udacity: Codable {
    let udacity: Login
    
    enum CodingKeys: String, CodingKey {
        case udacity
    }
}
