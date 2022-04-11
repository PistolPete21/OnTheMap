//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/27/21.
//

import Foundation

struct SessionResponse: Codable {
    let account: Account
    let session: Session
    
    enum CodingKeys: String, CodingKey {
        case account
        case session
    }
}
