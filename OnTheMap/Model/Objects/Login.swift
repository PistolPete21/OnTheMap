//
//  Login.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/27/21.
//

import Foundation

struct Login: Codable {
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
}
