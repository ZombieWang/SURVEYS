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

// MARK: Singleton classes don't care about reference cycle because they won't be released.
final class ServiceManager {
	static let shared = ServiceManager()
	private let _urls: [String: String] = ["query": "https://nimbl3-survey-api.herokuapp.com/surveys.json",
	                                       "getToken": "https://nimbl3-survey-api.herokuapp.com/oauth/token"]
	private let _tokenParams: [String: String] = ["grant_type": "password",
	                                              "username": "carlos@nimbl3.com",
	                                              "password": "antikera"]
	private var requestUrlCache: URL?
	
	typealias TokenCompletionHandler = (_ tokenString: String?, _ error: ServiceManagerError?) -> Void
	typealias QueryCompletionHandler = (_ json: JSON?, _ error: ServiceManagerError?) -> Void
	
	var urls: [String: String] {
		get {
			return _urls
		}
	}
	
	private init() {}
	
	func getToken(completion: @escaping TokenCompletionHandler) {
		guard let getTokenUrlString = _urls["getToken"],
			let tokenUrl = URL(string: getTokenUrlString) else {
				completion(nil, .getTokenError("Unwrap optionals failed"))
				return
		}
		
		Alamofire.request(tokenUrl,
		                  method: .post,
		                  parameters: _tokenParams)
			.responseData { response in
				guard response.error == nil else {
					completion(nil, .connectionError)
					return
				}
				
				guard let data = response.result.value else {
					completion(nil, .fetchDataError)
					return
				}
				
				let json = JSON(data: data)
				
				guard let token = json["access_token"].string else {
					completion(nil, .getTokenError("Parse JSON failed"))
					return
				}
				
				guard let urlString = self._urls["query"], let url = URL(string: urlString) else {
					completion(nil, .getTokenError("Unwrap optionals failed"))
					return
				}
				
				do {
					try Keychain(server: url, protocolType: .https).set(token, key: "token")
					
					completion(token, nil)
				} catch {
					completion(nil, .getTokenError("Save to keychain failed"))
				}
		}
	}
	
	func query(args: [String: String]? = nil, completion: @escaping QueryCompletionHandler) {
		guard let queryUrlString = _urls["query"],
			let queryUrl = URL(string: queryUrlString) else {
				completion(nil, .queryError("Unwrap optionals failed"))
				return
		}
		
		guard let tokenData = try? Keychain(server: queryUrl, protocolType: .https).get("token"),
			let token = tokenData,
			let requestUrl = URL(string: "\(queryUrlString)\(token)") else {
				completion(nil, .getTokenError("Get token from keychain failed"))
				return
		}
		
		var argument = ["access_token": token]
		if let args = args {
			argument += args
		}
		
		let url = requestUrlCache != nil ? requestUrlCache! : requestUrl
		
		Alamofire.request(url, method: .get, parameters: argument).responseData { (response) in
			guard response.error == nil else {
				completion(nil, .connectionError)
				return
			}
			
			guard let statusCode = response.response?.statusCode, statusCode != 401 else {
				self.requestUrlCache = requestUrl
				
				completion(nil, .unauthorized)
				return
			}
			
			guard let data = response.result.value else {
				completion(nil, .fetchDataError)
				return
			}
			
			completion(JSON(data: data), nil)
		}
	}
	
	func restartCachedRequest(completion: @escaping QueryCompletionHandler) {
		guard requestUrlCache != nil else {
			completion(nil, .noCachedRequest)
			return
		}
		
		query(completion: { (json, error) in
			self.requestUrlCache = nil
			
			if let error = error {
				completion(nil, error)
			}
			
			completion(json, nil)
		})
	}
}
