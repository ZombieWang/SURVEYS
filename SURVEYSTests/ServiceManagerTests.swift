//
//  ServiceManagerTests.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import XCTest
import SwiftyJSON
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
    
    func testProps() {
        XCTAssertNotNil(sut.token)
        XCTAssertNotNil(sut.urls)
        XCTAssertNotNil(sut.tokenParams)
    }
    
    func testGetToken() {
        let exp = expectation(description: #function)
        
        sut.getToken { (response) in
            switch response {
            case .result(let token):
                XCTAssertNotNil(token)
                exp.fulfill()
            case .failed:
                XCTFail("fetch new token failed")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testQuery() {
        let exp = expectation(description: #function)
        
        sut.query(arg: nil) { (response) in
            switch response {
            case .result:
                exp.fulfill()
            case .failed:
                XCTFail("fetch failed")
            }
        }
        
        sut.query(arg: ["page": "1", "per_page": "10"]) { (response) in
            switch response {
            case .result:
                exp.fulfill()
            case .failed:
                XCTFail("fetch with parameters failed")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
