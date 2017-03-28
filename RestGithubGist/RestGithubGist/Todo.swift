//
//  Todo.swift
//  RestGithubGist
//
//  Created by Jimmy Hoang on 3/24/17.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

import Foundation

class Todo {
    var title: String
    var id: Int?
    var userId: Int
    var completed: Bool
    
    required init(title: String, id: Int?, userId: Int, completed: Bool) {
        self.title = title
        self.id = id
        self.userId = userId
        self.completed = completed
    }
    
    func description() -> String {
        return "ID: \(self.id), " + "UserId: \(self.userId)" + "Title: \(self.title)" + "Completed: \(self.completed)"
    }
}
