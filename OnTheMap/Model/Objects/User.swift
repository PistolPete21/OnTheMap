//
//  User.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/27/21.
//

import Foundation

struct User : Codable {
    let firstName: String
    let lastName: String
    let mailingAddress: String?
    let occupation: String?
    let location: String?
    let bio: String?
    let linkedinUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case linkedinUrl = "linkedin_url"
        case mailingAddress = "mailing_address"
        case occupation
        case location
        case bio
    }
}
