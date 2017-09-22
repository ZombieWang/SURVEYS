//
//  SurveyDataModel.swift
//  SURVEYS
//
//  Created by Frank on 22/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation

class SurveyDataModel {
	typealias CompletionHandler = (_ surveys: [Survey]?, _ error: ServiceManagerError?) -> Void
	
	init() {
//		ServiceManager.shared.getToken { (response) in
//			switch response {
//			case .result(let token):
//				print("Successfully get token: \(token) and initiate")
//			case .failed:
//				print("Get token failed")
//			}
//		}
	}
	
	func requestData(arg: [String: String]? = nil, completion: @escaping CompletionHandler) {
		ServiceManager.shared.query(arg: arg) { (response) in
			switch response {
			case .failed:
				completion(nil, .fetchDataError)
			case .result(let json):
				var surveys = [Survey]()
				
				_ = json.map({ (_, json) in
					if let id = json["id"].string, let title = json["title"].string, let description = json["description"].string, let coverImageUrl = json["cover_image_url"].string {
						let survey = Survey(id: id, title: title, description: description, coverImageUrl: "\(coverImageUrl)l")
						
							surveys.append(survey)
					}
				})
				
				completion(surveys, nil)
			}
		}
	}
}
