//
//  Endpoint.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import Foundation


/// Enum to handle building URL paths and assigning HTTP method types for all API endpoints to be used by the buildRequest function in NetworkingManager
enum EndPoint {

    // all of the API endpoints being accessed by the app, with required parameters
    case trivia(amount: Int)

    
    // defines the method type for each of the API endpoints from the MethodType enum
    var methodType: MethodType {
        switch self {
        case .trivia:
            return .GET
        }
    }
    
    
    // defines the URL path and applies parameters as required
    var path: String {
        switch self {
        case .trivia:
            return "/api.php"
        }
    }
    
    // adds query items to path as required
    var queryItems: [String: String]? {
        switch self {
        case .trivia(let amount):
            return ["amount": "\(amount)"]
        }
    }

    // builds up all the components of the URL, adding the path and query items from above
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "opentdb.com"
        urlComponents.path = path
        
        var requestQueryItems = [URLQueryItem]()
        queryItems?.forEach{ item in
            requestQueryItems.append(URLQueryItem(name: item.key, value: item.value))
        }
        
        if requestQueryItems.count > 0 {
            urlComponents.queryItems = requestQueryItems
        }
        return urlComponents.url
    }
}

// all HTTP method types
enum MethodType : Equatable {
    case GET
}
