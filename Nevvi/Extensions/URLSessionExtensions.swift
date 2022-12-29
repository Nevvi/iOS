//
//  URLSessionExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

extension URLSession {
    func fetchData<T: Decodable>(for url: URL, for authToken: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
            
        self.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }

            if let data = data {
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(object))
                } catch let decoderError {
                    completion(.failure(decoderError))
                }
            }
        }.resume()
    }
    
    func postData<T: Decodable>(for url: URL, for body: Encodable, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        do {
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(body)
        } catch(let error) {
            completion(.failure(error))
        }
            
        self.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }

            if let data = data {
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(object))
                } catch let decoderError {
                    completion(.failure(decoderError))
                }
            }
        }.resume()
    }
}
