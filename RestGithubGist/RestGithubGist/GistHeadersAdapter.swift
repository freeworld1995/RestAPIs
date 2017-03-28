//
//  GistHeadersAdapter.swift
//  RestGithubGist
//
//  Created by Jimmy Hoang on 3/25/17.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

import Foundation
import Alamofire

class GistHeadersAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        return urlRequest
    }
}
