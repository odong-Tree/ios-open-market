//
//  Parser.swift
//  OpenMarket
//
//  Created by 김동빈 on 2021/01/25.
//

import Foundation

struct Parser<T: Codable> {
    typealias URLSessionHandling = (Data?, URLResponse?, Error?) -> Void
    typealias ResultHandling = (Result<Any, Error>) -> ()
    
    func request(url: URL, data: Data? = nil, httpMethod: HTTPMethod, completionHandler: @escaping URLSessionHandling) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = data
        
        if httpMethod == .post, httpMethod == .patch, httpMethod ==  .delete {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // get에서 setValue 넣으면..?
        }
        
        switch httpMethod {
        case .get, .delete:
            URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
        case .post, .patch:
            URLSession.shared.uploadTask(with: request, from: data, completionHandler: completionHandler).resume()
        }
    }
    
    func encodeData(object: T?, result: @escaping ResultHandling) {
        guard let data = try? JSONEncoder().encode(object) else {
            
        }
    }
    
    func abc(object: T?, url: URL, httpMethod: HTTPMethod, result: @escaping ResultHandling) {
        guard let data = try? JSONEncoder().encode(object) else {
            result(.failure(NetworkingError.failedEncoding))
            return
        }
        
        self.request(url: url, data: data, httpMethod: httpMethod) { (data, response, error) in
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
            
//            if httpMethod == .get {
//                do {
//                    let decodedData = try JSONDecoder().decode(T.self, from: data)
//                    result(.success(decodedData))
//                } catch {
//                    result(.failure(error))
//                }
//            } else {
//                result(.success(data))
//            }
        }
    }
}

//import Foundation
//
//struct Parser<T: Codable> {
//    typealias ResultTypeHandling = (Result<T, Error>) -> ()
//    typealias ResultDataHandling = (Result<Data, Error>) -> ()
//
//    static func parsingData(url: URL, httpMethod: HTTPMethod, object: T, result: @escaping ResultDataHandling) {
//        guard let encodedData = try? JSONEncoder().encode(object) else {
//            result(.failure(NetworkingError.failedEncoding))
//            return
//        }
//        //decode 해줘야함
//
//        APIManager.request(url: url, data: encodedData, httpMethod: httpMethod) { (data: Data?, response: URLResponse?, error: Error?) in
//            guard error == nil else {
//                result(.failure(NetworkingError.failedRequest))
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse,
//                  (200...299).contains(response.statusCode) else {
//                result(.failure(NetworkingError.failedResponse))
//                return
//            }
//
//            guard let data = data else {
//                result(.failure(NetworkingError.noData))
//                return
//            }
//
//            result(.success(data))
//        }
//    }
    
//    static func decodeData(url: URL, httpMethod: HTTPMethod, result: @escaping ResultTypeHandling) {
//        APIManager.request(url: url, data: nil, httpMethod: httpMethod) { (data: Data?, response: URLResponse?, error: Error?) in
//            guard error == nil else {
//                result(.failure(NetworkingError.failedRequest))
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse,
//                  (200...299).contains(response.statusCode) else {
//                result(.failure(NetworkingError.failedResponse))
//                return
//            }
//
//            guard let data = data else {
//                result(.failure(NetworkingError.noData))
//                return
//            }
//
//            do {
//                let decodedData = try JSONDecoder().decode(T.self, from: data)
//                result(.success(decodedData))
//            } catch {
//                result(.failure(error))
//            }
//        }
//    }
    
//    static func postData(url: URL, httpMethod: HTTPMethod, object: T, result: @escaping ResultDataHandling) {
//        guard let encodedData = try? JSONEncoder().encode(object) else {
//            result(.failure(NetworkingError.failedEncoding))
//            return
//        }
//
//        APIManager.request(url: url, data: encodedData, httpMethod: httpMethod) { (data: Data?, response: URLResponse?, error: Error?) in
//            guard error == nil else {
//                result(.failure(NetworkingError.failedRequest))
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse,
//                  (200...299).contains(response.statusCode) else {
//                result(.failure(NetworkingError.failedResponse))
//                return
//            }
//
//            guard let data = data else {
//                result(.failure(NetworkingError.noData))
//                return
//            }
//
//            result(.success(data))
//        }
//    }
//
//    static func patchData(url: URL, object: T, result: @escaping ResultDataHandling) {
//        guard let encodedData = try? JSONEncoder().encode(object) else {
//            result(.failure(NetworkingError.failedEncoding))
//            return
//        }
//
//        APIManager.requestPATCH(url: url, patchData: encodedData) { (data: Data?, response: URLResponse?, error: Error?) in
//            guard error == nil else {
//                result(.failure(NetworkingError.failedRequest))
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse,
//                  (200...299).contains(response.statusCode) else {
//                result(.failure(NetworkingError.failedResponse))
//                return
//            }
//
//            guard let data = data else {
//                result(.failure(NetworkingError.noData))
//                return
//            }
//
//            result(.success(data))
//        }
//    }
//
//    static func deleteData(url: URL, object: T, result: @escaping ResultDataHandling) {
//        guard let encodedData = try? JSONEncoder().encode(object) else {
//            result(.failure(NetworkingError.failedEncoding))
//            return
//        }
//
//        APIManager.requestDELETE(url: url, deleteData: encodedData) { (data: Data?, response: URLResponse?, error: Error?) in
//            guard error == nil else {
//                result(.failure(NetworkingError.failedRequest))
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse,
//                  (200...299).contains(response.statusCode) else {
//                result(.failure(NetworkingError.failedResponse))
//                return
//            }
//
//            guard let data = data else {
//                result(.failure(NetworkingError.noData))
//                return
//            }
//
//            result(.success(data))
//        }
//    }
}
