//
//  Response.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation

enum Response<T> {
    case result(T)
    case failed
}
