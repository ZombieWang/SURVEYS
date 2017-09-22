//
//  Constants.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import UIKit

protocol SegueHandlerType {
	associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
	func performSegueWithIdentifier(segueIdentifier: SegueIdentifier, sender: Any?) {
		performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
	}
	
	func segueIdentifierForSegue(_ segue: UIStoryboardSegue) -> SegueIdentifier {
		guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
			fatalError("Invalid segue identifier: \(String(describing: segue.identifier))")
		}
		
		return segueIdentifier
	}
}
