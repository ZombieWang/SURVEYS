//
//  ImageFetchManager.swift
//  SURVEYS
//
//  Created by Frank on 19/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Use struct to prevent protential reference cycle problem
struct ImageFetchManager: ImageFetcher {
    static func fetch(url: URL, completion: @escaping (Response<Data>) -> Void) {
        Alamofire.request(url).responseData { (response) in
            guard let data = response.result.value else {
                completion(.failed)
                
                return
            }
            
            completion(.result(data))
        }
    }
}
