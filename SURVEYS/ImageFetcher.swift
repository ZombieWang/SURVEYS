//
//  ImageFetcher.swift
//  SURVEYS
//
//  Created by Frank on 19/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation

protocol ImageFetcher {
    static func fetch(url: URL, completion: @escaping (Response<Data>) -> Void)
}
