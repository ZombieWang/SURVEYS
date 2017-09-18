//
//  ServiceManager.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

final class ServiceManager: ApiManager {
    static let shared = ServiceManager()
    
    private var _token: String?
    private let _urls: [String: String] = ["query": "https://nimbl3-survey-api.herokuapp.com/surveys.json?access_token=", "getToken": "https://nimbl3-survey-api.herokuapp.com/oauth/token?"]
    private let _tokenParams = ["grant_type": "password", "username": "carlos@nimbl3.com", "password": "antikera"]
    
    var token: String? {
        get {
            return _token
        }
    }
    
    var urls: [String: String] {
        get {
            return _urls
        }
    }
    var tokenParams: [String: String] {
        get {
            return _tokenParams
        }
    }
    
    private init() {}
    
    func getToken(completion: @escaping (Response<String>) -> Void) {
        Alamofire.request(URL(string: urls["getToken"]!)!, method: .post, parameters: tokenParams).responseData { (response) in
            if let data = response.result.value {
                let json = JSON(data: data)
                
                if let token = json["access_token"].string {
                    try? Keychain(server: URL(string: self.urls["query"]!)!, protocolType: .https).set(json["access_token"].string!, key: "token")
                    self._token = token
                    completion(.result(token))
                } else {
                    completion(.failed)
                }
            } else {
                completion(.failed)
            }
        }
    }
    
    func query(arg: [String: String]?, completion: @escaping (Response<JSON>) -> Void) {
        if let token = try? Keychain(server: URL(string: self.urls["query"]!)!, protocolType: .https).get("token") {
            _token = token
        }
        
        guard let token = token else {
            completion(.failed)
            
            return
        }
        
        Alamofire.request(URL(string: "\(urls["query"]!)\(token)")!, method: .get, parameters: arg).responseData { (response) in
            if let data = response.result.value {
                completion(.result(JSON(data: data)))
            } else {
                completion(.failed)
            }
        }
    }
}
