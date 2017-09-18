//
//  ApiManager.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//
import Foundation
import SwiftyJSON

protocol ApiManager {
    var token: String? { get }
    var urls: [String: String] { get }
    var tokenParams: [String: String] { get }
    
    func getToken(completion: @escaping (Response<String>) -> Void)
    func query(arg: [String: String]?, completion: @escaping (Response<JSON>) -> Void)
}
