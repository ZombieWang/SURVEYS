//
//  SurveyDataModel.swift
//  SURVEYS
//
//  Created by Frank on 22/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import KeychainAccess
import SwiftyJSON

class SurveyDataModel {
	typealias CompletionHandler = (_ surveys: [Survey]?, _ error: ServiceManagerError?) -> Void
	
	init() {
		ServiceManager.shared.getToken { (token, error) in
			guard error == nil, let token = token else {
				print("Get token failed")
				return
			}
			
			print("Successfully get new token: \(token)")
		}
	}
	
	func requestData(arg: [String: String]? = nil, completion: @escaping CompletionHandler) {
		ServiceManager.shared.query { (json, error) in
			if let error = error {
				switch error {
				case .unauthorized:
					ServiceManager.shared.getToken(completion: { (_, error) in
						if let error = error {
							completion(nil, error)
						}
						
						ServiceManager.shared.query { (json, error) in
							if let error = error {
								completion(nil, error)
							} else if let json = json {
								completion(self.appendSurveys(json), nil)
							}
						}
					})
				default:
					completion(nil, error)
				}
			} else if let json = json {
				completion(self.appendSurveys(json), nil)
			}
		}
	}
	
	private func appendSurveys(_ json: JSON) -> [Survey] {
		var surveys = [Survey]()
		
		_ = json.map({ (_, json) in
			if let id = json["id"].string, let title = json["title"].string, let description = json["description"].string, let coverImageUrl = json["cover_image_url"].string {
				let survey = Survey(id: id, title: title, description: description, coverImageUrl: "\(coverImageUrl)l")
				
				surveys.append(survey)
			}
		})
		
		return surveys
	}
}
