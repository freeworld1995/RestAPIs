//
//  GithubAPIManager.swift
//  RestGithubGist
//
//  Created by Jimmy Hoang on 3/24/17.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

import Foundation
import Alamofire

enum GithubAPIManagerError: Error {
    case network(error: Error)
    case apiProviderError(reason: String)
    case authCouldNot(reason: String)
    case authLost(reason: String)
    case objectSerialization(reasion: String)
}

class GithubAPIManager {
    static let shared = GithubAPIManager()
    
    func fetchPublicGists(pageToLoad: String?, completionHandler: @escaping (Result<[Gist]>, String?) -> ()) {
        if let urlString = pageToLoad {
            fetchGist(GistRouter.getAtPath(urlString), completionHandler: completionHandler)
        } else {
            fetchGist(GistRouter.getPublic(), completionHandler: completionHandler)
        }
    }
    
    func fetchGist(_ urlRequest: URLRequestConvertible, completionHandler: @escaping (Result<[Gist]>, String?) -> ()) {
        Alamofire.request(urlRequest).responseJSON { (response) in
            let result = self.gistArrayFromResponse(response: response)
            let next = self.parseNextPageFromHeaders(response: response.response)
            completionHandler(result, next)
        }
    }
    
    func imageFrom(urlString: String, completionHandler: @escaping (UIImage?, Error?) -> ()) {
        let _ = Alamofire.request(urlString).response { (dataResponse) in
            guard let data = dataResponse.data else {
                completionHandler(nil, dataResponse.error)
                return
            }
            
            let image = UIImage(data: data)
            completionHandler(image, nil)
        }
    }
    
    private func gistArrayFromResponse(response: DataResponse<Any>) -> Result<[Gist]> {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(GithubAPIManagerError.network(error: response.result.error!))
        }
        
        guard let jsonArray = response.result.value as? [[String:Any]] else {
            print("didn't get array gists as JSON from API")
            return .failure(GithubAPIManagerError.objectSerialization(reasion: "Did not get JSON dictionary in response"))
        }
        
        if let jsonDictionary = response.result.value as? [String:Any], let errorMessage = jsonDictionary["message"] as? String {
            return .failure(GithubAPIManagerError.apiProviderError(reason: errorMessage))
        }
        //
        //        var gists = [Gist]()
        //        for item in jsonArray {
        //            if let gist = Gist(json: item) {
        //                gists.append(gist)
        //            }
        //        }
        
        let gists = jsonArray.flatMap { Gist(json: $0) }
        
        return .success(gists)
    }
    
    private func parseNextPageFromHeaders(response: HTTPURLResponse?) -> String? {
        guard let linkHeader = response?.allHeaderFields["Link"] as? String else {
            return nil
        }
        /* looks like: <https://...?page=2>; rel="next", <https://...?page=6>; rel="last" */
        // so split on ","
        let components = linkHeader.characters.split { $0 == "," }.map { String($0) }
        // now we have 2 lines like '<https://...?page=2>; rel="next"'
        for item in components {
            // see if it's "next"
            let rangeOfNext = item.range(of: "rel=\"next\"", options: [])
            guard rangeOfNext != nil else {
                continue
            }
            // this is the "next" item, extract the URL
            let rangeOfPaddedURL = item.range(of: "<(.*)>;",
                                              options: .regularExpression,
                                              range: nil,
                                              locale: nil)
            guard let range = rangeOfPaddedURL else {
                return nil
            }
            
            let nextURL = item.substring(with: range)
            
            // strip off the < and >;
            let start = nextURL.index(range.lowerBound, offsetBy: 1)
            let end = nextURL.index(range.upperBound, offsetBy: -2)
            let trimmedRange = start ..< end
            return nextURL.substring(with: trimmedRange)
        }
        return nil
    }
    
    func clearCache() {
        let cache = URLCache.shared
        cache.removeAllCachedResponses()
    }
}
