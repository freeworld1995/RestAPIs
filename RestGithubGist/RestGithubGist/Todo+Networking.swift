//
//  Todo+Networking.swift
//  RestGithubGist
//
//  Created by Jimmy Hoang on 3/24/17.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

import Foundation
import Alamofire

enum BackendError: Error {
    case objectSerializationn(reason: String)
}

extension Todo {
    convenience init?(json: [String: Any]) {
        guard let title = json["title"] as? String,
            let userId = json["userId"] as? Int,
            let completed = json["completed"] as? Bool else {
                return nil
        }
        
        let idValue = json["id"] as? Int
        
        self.init(title: title, id: idValue, userId: userId, completed: completed)
    }
    
    func toJSON() -> [String:Any] {
        var json = [String:Any]()
        json["title"] = title
        if let id = id {
            json["id"] = id
        }
        json["userId"] = userId
        json["completed"] = completed
        return json
    }
    
    func save(completionHandler: @escaping (Result<Todo>) ->()) {
        let fields = self.toJSON()
        Alamofire.request(TodoRouter.create(fields)).responseJSON { (response) in
            let result = Todo.todoFromReponse(response: response)
            completionHandler(result)
        }
    }
    
    class func todoByID(id: Int, completionHandler: @escaping (Result<Todo>) -> ()) {
        Alamofire.request(TodoRouter.get(id)).responseJSON { (response) in
            
            let result = Todo.todoFromReponse(response: response)
            
            completionHandler(result)
        }
    }
    
    private class func todoFromReponse(response: DataResponse<Any>) -> Result<Todo> {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(response.result.error!)
        }
        
        guard let json = response.result.value as? [String:Any] else {
            print("didn't get todo object as JSON from API")
            return .failure(BackendError.objectSerializationn(reason: "Did not get JSON dictionary in response"))
        }
        
        guard let todo = Todo(json: json) else {
            return .failure(BackendError.objectSerializationn(reason: "Could not create Todo object from JSON"))
        }
        
        return .success(todo)
    }
}
