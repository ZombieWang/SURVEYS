//
//  ImageFetchManagerTests.swift
//  SURVEYS
//
//  Created by Frank on 19/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import XCTest
@testable import SURVEYS

class ImageFetchManagerTests: XCTestCase {
    var sut: ImageFetchManager!
    
    override func setUp() {
        super.setUp()
        
        sut = ImageFetchManager()
        XCTAssertNotNil(sut)
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testFetch() {
        let exp = expectation(description: #function)
        
        let url = URL(string: "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_l")!
        
        ImageFetchManager.fetch(url: url) { (response) in
            switch response {
            case .result:
                exp.fulfill()
            case .failed:
                XCTFail("get image data failed")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
