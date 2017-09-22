//
//  ServiceManagerTests.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import XCTest
import SwiftyJSON
import KeychainAccess
@testable import SURVEYS

class ServiceManagerTests: XCTestCase {
	var sut: ServiceManager!
	
	override func setUp() {
		super.setUp()
		
		sut = ServiceManager.shared
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testGetToken() {
		let exp = expectation(description: #function)
		
		sut.getToken { (token, error) in
			if error != nil {
				XCTFail("get token failed")
			} else if token != nil {
				exp.fulfill()
			}
		}
		
		waitForExpectations(timeout: 10, handler: nil)
	}
	
	func testQuery() {
		let exp = expectation(description: #function)
		
		sut.query { (json, error) in
			if error != nil {
				XCTFail("fetch failed")
			} else if let json = json,
				let id = json[0]["id"].string,
				let title = json[0]["title"].string,
				let description = json[0]["description"].string,
				let coverImageUrl = json[0]["cover_image_url"].string {
				let survey = Survey(id: id, title: title, description: description, coverImageUrl: "\(coverImageUrl)l")
				XCTAssertNotNil(survey)
			}
		}
		
		sut.query(args: ["page": "1", "per_page": "10"]) { (json, error) in
			if error != nil {
				XCTFail("fetch with parameters failed")
			} else if let json = json,
				let id = json[0]["id"].string,
				let title = json[0]["title"].string,
				let description = json[0]["description"].string,
				let coverImageUrl = json[0]["cover_image_url"].string {
				let survey = Survey(id: id, title: title, description: description, coverImageUrl: "\(coverImageUrl)l")
				XCTAssertNotNil(survey)
				
				exp.fulfill()
			}
		}
		
		waitForExpectations(timeout: 15, handler: nil)
	}
	
	func testRestartCachedRequest() {
		let exp = expectation(description: #function)
		
		guard let urlString = sut.urls["query"], let url = URL(string: urlString) else {
			XCTFail("Unwrap failed")
			return
		}
		
		try? Keychain(server: url, protocolType: .https).set("fakeToken", key: "token")
		let tokenData = try? Keychain(server: url, protocolType: .https).get("token")
		print("Set fake token to ketchain, current token: \(tokenData!!)")
		
		sut.query { (json, error) in
			if let error = error {
				switch error {
				case .unauthorized:
					self.sut.getToken(completion: { (token, error) in
						if error != nil {
							XCTFail("Get token failed")
						} else {
							print("Current token is: \(token!)")
							self.sut.restartCachedRequest(completion: { (json, error) in
								if error != nil {
									XCTFail("Restart cached request failed")
								} else if let json = json,
									let id = json[0]["id"].string,
									let title = json[0]["title"].string,
									let description = json[0]["description"].string,
									let coverImageUrl = json[0]["cover_image_url"].string {
									let survey = Survey(id: id, title: title, description: description, coverImageUrl: "\(coverImageUrl)l")
									XCTAssertNotNil(survey)
									
									exp.fulfill()
								}
							})
						}
					})
				default:
					XCTFail("Query failed")
				}
			}
		}
		
		waitForExpectations(timeout: 20, handler: nil)
	}
}
