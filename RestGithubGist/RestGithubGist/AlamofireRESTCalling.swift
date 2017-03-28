//
//  AlamofireRESTCalling.swift
//  RestGithubGist
//
//  Created by Jimmy Hoang on 3/24/17.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

import UIKit
import Alamofire

class AlamofireRESTCalling: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func get() {
        
        Alamofire.request(TodoRouter.get(1)).responseJSON { (response) in
            guard response.result.error == nil else {
                print("error calling Get on todos/1")
                print(response.result.error!)
                return
            }
            
            guard let json = response.result.value as? [String: Any] else {
                print("Error: \(response.result.error)")
                return
            }
            
            guard let todoTitle = json["title"] as? String else {
                print("cannot get title from json")
                return
            }
            
            print(todoTitle)
        }
        
    }
    
    func post() {
        
        let newTodo: [String: Any] = ["title": "go to supermarket", "completed": 0, "userId": 1]
        
        Alamofire.request(TodoRouter.create(newTodo)).responseJSON { (response) in
            guard response.result.error == nil else {
                print("error calling POST on todos/1")
                return
            }
            
            guard let json = response.result.value as? [String: Any] else {
                print("didnt get todo as json from API")
                print("Error: \(response.result.error)")
                return
            }
            
            guard let todoTitle = json["title"] as? String else {
                print("cannot get title from json")
                return
            }
            
            print("title of json: \(todoTitle)")
        }
    }
    
    func delete() {
        
        Alamofire.request(TodoRouter.delete(1)).responseJSON { (response) in
            guard response.result.error == nil else {
                print("cannot call delete on todos/1")
                print("Error: \(response.result.error!)")
                return
            }
            
            print("delete done")
        }
    }
    
}
