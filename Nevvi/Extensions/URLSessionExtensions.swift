//
//  URLSessionExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

extension URLSession {
    enum HttpError : Error, LocalizedError, Identifiable {
        case clientError
        case serverError
        
        static func parse(statusCode: Int) -> HttpError {
            if statusCode >= 400 && statusCode < 500 {
                return HttpError.clientError
            } else {
                return HttpError.serverError
            }
        }
        
        var id: String {
            self.localizedDescription
        }
        
        var errorDescription: String? {
            switch self {
            case .clientError:
                return NSLocalizedString("Client error", comment: "")
            case .serverError:
                return NSLocalizedString("Server error", comment: "")
            }
        }

    }
    
    func fetchData<T: Decodable>(for url: URL, for authToken: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        execute(request: request, completion: completion)
    }
    
    func postData<T: Decodable>(for url: URL, for body: Encodable, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        do {
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(body)
        } catch(let error) {
            completion(.failure(error))
        }
            
        execute(request: request, completion: completion)
    }
    
    func patchData<T: Decodable>(for url: URL, for body: Encodable, for authToken: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        do {
            request.httpMethod = "PATCH"
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
        } catch(let error) {
            completion(.failure(error))
        }
            
        execute(request: request, completion: completion)
    }
    
    private func execute<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        self.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async{
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let httpResponse = response as? HTTPURLResponse
                if (httpResponse != nil && httpResponse!.statusCode >= 400) {
                    completion(.failure(HttpError.parse(statusCode: httpResponse!.statusCode)))
                    return
                }
                
                if let data = data {
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(object))
                    } catch let decoderError {
                        completion(.failure(decoderError))
                    }
                }
            }
        }.resume()
    }
}
