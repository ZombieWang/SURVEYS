//
//  Survey.swift
//  SURVEYS
//
//  Created by Frank on 19/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation

struct Survey {
    let id: String
    let title: String
    let description: String
    let coverImageURL: URL
    
    init(id: String, title: String, description: String, coverImageUrl: String) {
        self.id = id
        self.title = title
        self.description = description
        self.coverImageURL = URL(string: coverImageUrl)!
    }
}
