//
//  ModelData.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import Combine

final class ModelData: ObservableObject {
    @Published var connectionResponse: ConnectionResponse = load("connectionResponse.json")
    @Published var connection: Connection = load("connectionData.json")
    @Published var user: User = load("userData.json")
    @Published var usersResponse: ConnectionResponse = load("usersResponse.json")
    @Published var requests: [ConnectionRequest] = load("requestsData.json")
    @Published var groups: [ConnectionGroup] = load("connectionGroups.json")
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
