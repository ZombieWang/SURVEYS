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
	
//	private var _token: String?
	private let _urls: [String: String] = ["query": "https://nimbl3-survey-api.herokuapp.com/surveys.json?access_token=", "getToken": "https://nimbl3-survey-api.herokuapp.com/oauth/token?"]
	private let _tokenParams = ["grant_type": "password", "username": "carlos@nimbl3.com", "password": "antikera"]
	
	typealias TokenCompletionHandler = (_ tokenString: String?, _ error: ServiceManagerError?) -> Void
	typealias QueryCompletionHandler = (_ json: JSON?, _ error: ServiceManagerError?) -> Void
	
	private init() {}
	
	func getToken_(completion: @escaping TokenCompletionHandler) {
		Alamofire.request(URL(string: _urls["getToken"]!)!,
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
	
//	func getToken(completion: @escaping (Response<String>) -> Void) {
//		Alamofire.request(URL(string: _urls["getToken"]!)!, method: .post, parameters: _tokenParams).responseData { (response) in
//			print(response)
//			print(response.error)
//			print(response.value)
//			if let data = response.result.value {
//				let json = JSON(data: data)
//
//				if let token = json["access_token"].string {
//					try? Keychain(server: URL(string: self._urls["query"]!)!, protocolType: .https).set(json["access_token"].string!, key: "token")
//					self._token = token
//					completion(.result(token))
//				} else {
//					completion(.failed)
//				}
//			} else {
//				completion(.failed)
//			}
//		}
//	}
	
	//    func refreshToken(inEveryTimeInterval interval: TimeInterval) {
	//        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
	//            self.getToken(completion: { (response) in
	//                switch response {
	//                case .failed:
	//                    print("Failed")
	//                case .result(let token):
	//                    print("Token: \(token) saved to keychain.")
	//                }
	//            })
	//
	//        }
	//        timer.fire()
	//    }
	
	func query_(args: [String: String]? = nil, completion: @escaping QueryCompletionHandler) {
		guard let token = try? Keychain(server: URL(string: self._urls["query"]!)!, protocolType: .https).get("token") else {
			
			completion(nil, .getTokenError("Get token from keychain failed"))
			return
		}
		
		guard let queryUrlString = _urls["query"], let url = URL(string: "\(queryUrlString)\(token)") else {
			completion(nil, .queryError("Unwrap optionals failed"))
			return
		}
		
		Alamofire.request(url, method: .get, parameters: args).responseData { (response) in
			guard response.error == nil else {
				completion(nil, .connectionError)
				return
			}
			
			guard let data = response.result.value else {
				completion(nil, .fetchDataError)
				return
			}
			
			completion(JSON(data: data), nil)
		}

	}
	
	func query(arg: [String: String]? = nil, completion: @escaping (Response<JSON>) -> Void) {
		guard let token = try? Keychain(server: URL(string: self._urls["query"]!)!, protocolType: .https).get("token") else {

			// TODO: completion handler
			return
		}
		
//		guard let token = _token else {
//			completion(.failed)
//
//			return
//		}
		
		Alamofire.request(URL(string: "\(_urls["query"]!)\(token)")!, method: .get, parameters: arg).responseData { (response) in
			if let data = response.result.value {
				completion(.result(JSON(data: data)))
			} else {
				completion(.failed)
			}
		}
	}
}
