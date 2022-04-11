//
//  MapClient.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/27/21.
//

import Foundation

class MapClient {
    
    struct Auth {
        static var id = ""
        static var expiration = ""
        static var registed = false
        static var userId = ""
        static var objectId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case userData
        case getStudentLocation
        case studentLocation
        case putStudentLocation
        
        var stringValue: String {
            switch self {
            case .login: return Endpoints.base + "/session"
            case .userData: return Endpoints.base + "/users/" + Auth.userId
            case .getStudentLocation:
                var urlComps = URLComponents(string: Endpoints.base + "/StudentLocation")
                let queryParams = [URLQueryItem(name: "limit", value: "100"), URLQueryItem(name: "order", value: "-updatedAt")]
                urlComps?.queryItems = queryParams
                let result = urlComps?.url?.absoluteString ?? ""
                print(result)
                return result
            case .studentLocation: return Endpoints.base + "/StudentLocation"
            case .putStudentLocation: return "/StudentLocation/" + Auth.objectId
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, isAuthenticated: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            var newData = data
            do {
                if isAuthenticated {
                    let range = (5..<data.count)
                    newData = data.subdata(in: range)
                    print(String(data: newData, encoding: .utf8)!)
                }
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, isAuthenticated: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        if url == Endpoints.login.url {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            var newData = data
            do {
                if isAuthenticated {
                    let range = (5..<data.count)
                    newData = data.subdata(in: range)
                    print(String(data: newData, encoding: .utf8)!)
                }
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
     
    class func getStudentLocations(completion: @escaping (StudentLocationsResponse?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getStudentLocation.url, responseType: StudentLocationsResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getUserData(completion: @escaping (User?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.userData.url, responseType:  User.self, isAuthenticated: true) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func login(email: String, password: String, completion: @escaping (SessionResponse?, Error?) -> Void) {
        let body = Udacity(udacity: Login(username: email, password: password))
        taskForPOSTRequest(url: Endpoints.login.url, responseType: SessionResponse.self, body: body, isAuthenticated: true) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func postStudentLocation(studentInformation: StudentInformation, completion: @escaping (StudentInformation?, Error?) -> Void) {
        let body = StudentInformation(createdAt: studentInformation.createdAt, firstName: studentInformation.firstName, lastName: studentInformation.lastName, latitude: studentInformation.latitude, longitude: studentInformation.longitude, mapString: studentInformation.mapString, mediaURL: studentInformation.mediaURL, objectId: studentInformation.objectId, uniqueKey: studentInformation.uniqueKey, updatedAt: studentInformation.updatedAt)
        taskForPOSTRequest(url: Endpoints.studentLocation.url, responseType: StudentInformation.self, body: body) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func putStudentLocation(studentInformation: StudentInformation, completion: @escaping (StudentInformation?, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.putStudentLocation.url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = StudentInformation(createdAt: studentInformation.createdAt, firstName: studentInformation.firstName, lastName: studentInformation.lastName, latitude: studentInformation.latitude, longitude: studentInformation.longitude, mapString: studentInformation.mapString, mediaURL: studentInformation.mediaURL, objectId: studentInformation.objectId, uniqueKey: studentInformation.uniqueKey, updatedAt: studentInformation.updatedAt)
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(StudentInformation.self, from: data)
                completion(responseObject, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    class func logout(completion: @escaping (Session?, Error?) -> Void) {
        let isAuthenticated: Bool = true
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            var newData = data
            do {
                if isAuthenticated {
                    let range = (5..<data.count)
                    newData = data.subdata(in: range)
                    print(String(data: newData, encoding: .utf8)!)
                }
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(LogoutResponse.self, from: newData)
                completion(responseObject.session, nil)
            } catch {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
        task.resume()
    }
}
