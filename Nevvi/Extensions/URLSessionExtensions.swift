//
//  URLSessionExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import UIKit
import Foundation

enum HttpError : Error, LocalizedError, Identifiable {
    case clientError(message: String)
    case serverError(message: String)
    case passwordResetError
            
    static func parse(statusCode: Int, error: String?) -> HttpError {
        if statusCode >= 400 && statusCode < 500 {
            if error != nil && error! == "Password reset required for the user" {
                return HttpError.passwordResetError
            }
            return HttpError.clientError(message: error ?? "Client error")
        } else {
            return HttpError.serverError(message: error ?? "Server error")
        }
    }
    
    var id: String {
        self.localizedDescription
    }
    
    var errorDescription: String? {
        switch self {
        case .clientError(let message):
            return NSLocalizedString(message, comment: "")
        case .serverError(let message):
            return NSLocalizedString(message, comment: "")
        case .passwordResetError:
            return NSLocalizedString("Password reset required", comment: "")
        }
    }
    
    static func ==(lhs: HttpError, rhs: HttpError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}

extension URLSession {
    
    func fetchData<T: Decodable>(for url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        execute(request: request, completion: completion)
    }
    
    func fetchData<T: Decodable>(for url: URL, with authorization: Authorization, completion: @escaping (Result<T, Error>) -> Void) {
        guard let token = authorization.getValidToken() else {
            // Token is expired, onAuthorizationFailed already called
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        execute(request: request, authorization: authorization, completion: completion)
    }
    
    func fetchData<T: Decodable>(for url: URL, for authToken: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        execute(request: request, completion: completion)
    }
    
    func postData<T: Decodable>(for url: URL, for body: Encodable, with authorization: Authorization, completion: @escaping (Result<T, Error>) -> Void) {
        guard let token = authorization.getValidToken() else {
            // Token is expired, onAuthorizationFailed already called
            return
        }
        
        var request = URLRequest(url: url)
        do {
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } catch(let error) {
            completion(.failure(error))
            return
        }
        execute(request: request, authorization: authorization, completion: completion)
    }
    
    func postData<T: Decodable>(for url: URL, for body: Encodable, for authToken: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        do {
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
        } catch(let error) {
            completion(.failure(error))
        }
            
        execute(request: request, completion: completion)
    }
    
    func postData<T: Decodable>(for url: URL, with authorization: Authorization, completion: @escaping (Result<T, Error>) -> Void) {
        guard let token = authorization.getValidToken() else {
            // Token is expired, onAuthorizationFailed already called
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        execute(request: request, authorization: authorization, completion: completion)
    }
    
    func postData<T: Decodable>(for url: URL, for authToken: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(authToken, forHTTPHeaderField: "Authorization")

        execute(request: request, completion: completion)
    }
    
    func postData<T: Decodable>(for url: URL, for authToken: String, for accessToken: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        request.setValue(accessToken, forHTTPHeaderField: "AccessToken")

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
    
    func patchData<T: Decodable>(for url: URL, for body: Encodable, with authorization: Authorization, completion: @escaping (Result<T, Error>) -> Void) {
        guard let token = authorization.getValidToken() else {
            // Token is expired, onAuthorizationFailed already called
            return
        }
        
        var request = URLRequest(url: url)
        do {
            request.httpMethod = "PATCH"
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } catch(let error) {
            completion(.failure(error))
            return
        }
        execute(request: request, authorization: authorization, completion: completion)
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
    
    func deleteData<T: Decodable>(for url: URL, with authorization: Authorization, completion: @escaping (Result<T, Error>) -> Void) {
        guard let token = authorization.getValidToken() else {
            // Token is expired, onAuthorizationFailed already called
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        execute(request: request, authorization: authorization, completion: completion)
    }
    
    func deleteData<T: Decodable>(for url: URL, for authToken: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(authToken, forHTTPHeaderField: "Authorization")

        execute(request: request, completion: completion)
    }
    
    func deleteData<T: Decodable>(for url: URL, for body: Encodable, with authorization: Authorization, completion: @escaping (Result<T, Error>) -> Void) {
        guard let token = authorization.getValidToken() else {
            // Token is expired, onAuthorizationFailed already called
            return
        }
        
        var request = URLRequest(url: url)
        do {
            request.httpMethod = "DELETE"
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } catch(let error) {
            completion(.failure(error))
            return
        }
        execute(request: request, authorization: authorization, completion: completion)
    }
    
    func postImage<T: Decodable>(for url: URL, for image: UIImage, with authorization: Authorization, completion: @escaping (Result<T, Error>) -> Void) {
        guard let token = authorization.getValidToken() else {
            // Token is expired, onAuthorizationFailed already called
            return
        }
        
        let request = MultipartFormDataRequest(url: url)
        let smallerImage = resizeImage(image: image, newWidth: 200)
        let fileName = "IMG_\(Int.random(in: 1000000..<10000000)).png"
        request.addDataField(named: "file", data: smallerImage.pngData()!, mimeType: "image/png", fileName: fileName)
        
        var urlRequest = request.asURLRequest()
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        self.execute(request: urlRequest, authorization: authorization, completion: completion)
    }
    
    func postImage<T: Decodable>(for url: URL, for image: UIImage, for authToken: String, completion: @escaping (Result<T, Error>) -> Void) {
        let request = MultipartFormDataRequest(url: url)
        let smallerImage = resizeImage(image: image, newWidth: 200)
        let fileName = "IMG_\(Int.random(in: 1000000..<10000000)).png"
        request.addDataField(named: "file", data: smallerImage.pngData()!, mimeType: "image/png", fileName: fileName)
        
        var urlRequest = request.asURLRequest()
        urlRequest.setValue(authToken, forHTTPHeaderField: "Authorization")

        self.execute(request: urlRequest, completion: completion)
    }
    
    func execute<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        self.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async{
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let httpResponse = response as? HTTPURLResponse
                
                if let data = data {
                    do {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(dateFormatter)
                        
                        if (httpResponse != nil && httpResponse!.statusCode >= 400) {
                            let error = try decoder.decode(String.self, from: data)
                            completion(.failure(HttpError.parse(statusCode: httpResponse!.statusCode, error: error)))
                            return
                        } else {
                            let object = try decoder.decode(T.self, from: data)
                            completion(.success(object))
                        }
                    } catch let decoderError {
                        completion(.failure(decoderError))
                    }
                } else if (httpResponse != nil && httpResponse!.statusCode >= 400) {
                    completion(.failure(HttpError.parse(statusCode: httpResponse!.statusCode, error: nil)))
                }
            }
        }.resume()
    }
    
    func execute<T: Decodable>(request: URLRequest, authorization: Authorization, completion: @escaping (Result<T, Error>) -> Void) {
        self.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async{
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let httpResponse = response as? HTTPURLResponse
                
                // Check for 401/403 errors and call onAuthorizationFailed
                if let httpResponse = httpResponse, (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                    print("Received \(httpResponse.statusCode) error - calling onAuthorizationFailed")
                    authorization.onAuthorizationFailed?()
                    return
                }
                
                if let data = data {
                    do {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(dateFormatter)
                        
                        if (httpResponse != nil && httpResponse!.statusCode >= 400) {
                            let error = try decoder.decode(String.self, from: data)
                            completion(.failure(HttpError.parse(statusCode: httpResponse!.statusCode, error: error)))
                            return
                        } else {
                            let object = try decoder.decode(T.self, from: data)
                            completion(.success(object))
                        }
                    } catch let decoderError {
                        completion(.failure(decoderError))
                    }
                } else if (httpResponse != nil && httpResponse!.statusCode >= 400) {
                    completion(.failure(HttpError.parse(statusCode: httpResponse!.statusCode, error: nil)))
                }
            }
        }.resume()
    }
}

struct MultipartFormDataRequest {
    private let boundary: String = UUID().uuidString
    private var httpBody = NSMutableData()
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func addTextField(named name: String, value: String) {
        httpBody.append(textFormField(named: name, value: value))
    }

    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

    func addDataField(named name: String, data: Data, mimeType: String, fileName: String) {
        httpBody.append(dataFormField(named: name, data: data, mimeType: mimeType, fileName: fileName))
    }

    private func dataFormField(named name: String,
                               data: Data,
                               mimeType: String,
                               fileName: String) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")

        return fieldData as Data
    }
    
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        httpBody.append("--\(boundary)--")
        request.httpBody = httpBody as Data
        return request
    }
}

extension NSMutableData {
  func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
}
