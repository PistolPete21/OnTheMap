//
//  LogoutResponse.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/28/21.
//

import Foundation

struct LogoutResponse: Codable {
    let session: Session
    
    enum CodingKeys: String, CodingKey {
        case session
    }
}
