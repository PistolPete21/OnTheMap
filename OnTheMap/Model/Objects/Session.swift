//
//  Session.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/27/21.
//

import Foundation

struct Session : Codable {
    let id: String
    let expiration: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case expiration
    }
}
