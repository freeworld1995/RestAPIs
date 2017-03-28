//
//  ViewController.swift
//  RestGithubGist
//
//  Created by Jimmy Hoang on 3/23/17.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

import UIKit
import Foundation

class TraditionalRESTCalling: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let todoEndPoint = "https://jsonplaceholder.typicode.com/todos"
        
        guard let todosURL = URL(string: todoEndPoint) else {
            print("Error: cannot create url")
            return
        }
        
        var todosUrlRequest = URLRequest(url: todosURL)
        todosUrlRequest.httpMethod = "POST"
        
        let newTodo: [String: Any] = ["title": "practicing make app", "completed": false, "userId": 1]
        let jsonTodo: Data
        
        do {
            jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
            todosUrlRequest.httpBody = jsonTodo
        } catch {
            print("Error: cannot create JSON from todo")
            return
        }
        
        let session = URLSession.shared
        
        //        let myCompletionHandler: (Data?, URLResponse?, Error?) -> Void = {
        //            (data, response, error) in
        //
        //            if let response = response {
        //                print(response)
        //            }
        //            if let error = error {
        //                print(error)
        //            }
        //        }
        
        let task = session.dataTask(with: todosUrlRequest) { (data, response, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error trying to convert data into JSON")
                    return
                }
                
                print("The todo is: \(todo)")
                
                guard let todoTitle = todo["title"] as? String else {
                    print("Could not get todo title from Json")
                    return
                }
                
                print("Title of todo: \(todoTitle)")
                
            } catch {
                print("error trying to convert data to json")
                return
            }

        }
        
        task.resume()
    }
    
}

