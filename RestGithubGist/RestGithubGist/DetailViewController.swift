//
//  DetailViewController.swift
//  RestGithubGist
//
//  Created by Jimmy Hoang on 3/25/17.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var detailItem: Gist? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
