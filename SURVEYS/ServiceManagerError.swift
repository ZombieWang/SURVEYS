//
//  Error.swift
//  SURVEYS
//
//  Created by Frank on 22/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation

enum ServiceManagerError: Error {
	case connectionError
	case fetchDataError
	case getTokenError(String)
	case queryError(String)
	case unauthorized
	case noCachedRequest
}
