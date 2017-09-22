//
//  Dictionary+Extention.swift
//  SURVEYS
//
//  Created by Frank on 23/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation

public extension Dictionary {
	public static func +=(lhs: inout Dictionary, rhs: Dictionary) {
		for (k, v) in rhs {
			lhs[k] = v
		}
	}
}
