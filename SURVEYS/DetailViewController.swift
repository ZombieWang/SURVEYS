//
//  DetailVC.swift
//  SURVEYS
//
//  Created by Frank on 19/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!

    var survey: Survey!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLbl.text = survey.title
        descriptionLbl.text = survey.description
    }
}
