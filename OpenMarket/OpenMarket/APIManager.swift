//
//  APIManager.swift
//  OpenMarket
//
//  Created by 김동빈 on 2021/01/25.
//

import Foundation

struct APIManager<T: Codable> {
    typealias URLSessionHandling = (Data?, URLResponse?, Error?) -> Void
    typealias ResultHandling = (Result<Any, Error>) -> ()
    
    static func requestHTTP(url: URL, data: Data? = nil, httpMethod: HTTPMethod, completionHandler: @escaping URLSessionHandling) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = data
        
        if httpMethod == .post, httpMethod == .patch, httpMethod == .delete {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        switch httpMethod {
        case .get, .delete:
            URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
        case .post, .patch:
            URLSession.shared.uploadTask(with: request, from: data, completionHandler: completionHandler).resume()
        }
    }
    
    static func handleRequest(object: T?, url: URL, httpMethod: HTTPMethod, result: @escaping ResultHandling) {
        let data: Data? = try? JSONEncoder().encode(object)
        
        self.requestHTTP(url: url, data: data, httpMethod: httpMethod) { (data, response, error) in
            guard error == nil else {
                result(.failure(NetworkingError.failedRequest))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                result(.failure(NetworkingError.failedResponse))
                return
            }
            
            guard let data = data else {
                result(.failure(NetworkingError.noData))
                return
            }
            
            switch httpMethod {
            case .get:
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    result(.success(decodedData))
                } catch {
                    result(.failure(NetworkingError.failedDecoding))
                }
            default:
                result(.success(data))
            }
        }
    }
}
