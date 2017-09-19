//
//  SurveyTests.swift
//  SURVEYS
//
//  Created by Frank on 19/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import XCTest
@testable import SURVEYS

class SurveyTests: XCTestCase {
    var sut: Survey!
    
    override func setUp() {
        super.setUp()
        
        sut = Survey(id: "d5de6a8f8f5f1cfe51bc", title: "Scarlett Bangkok", description: "We'd love ot hear from you!", coverImageUrl: "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_")
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testProps() {
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.title)
        XCTAssertNotNil(sut.description)
        XCTAssertNotNil(sut.coverImageURL)
    }
}
