//
//  RecentSearchesManager.swift
//  Nevvi
//
//  Created by Assistant on 12/26/25.
//

import Foundation

struct RecentSearch: Codable, Identifiable, Equatable {
    let id = UUID()
    let searchTerm: String
    let timestamp: Date
    
    init(searchTerm: String) {
        self.searchTerm = searchTerm
        self.timestamp = Date()
    }
    
    static func == (lhs: RecentSearch, rhs: RecentSearch) -> Bool {
        lhs.searchTerm.lowercased() == rhs.searchTerm.lowercased()
    }
}

class RecentSearchesManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let key = "recentSearches.v1"
    private let maxSearches = 3
    
    @Published private(set) var recentSearches: [RecentSearch] = []
    
    init() {
        loadRecentSearches()
    }
    
    private func loadRecentSearches() {
        guard let data = userDefaults.data(forKey: key),
              let searches = try? JSONDecoder().decode([RecentSearch].self, from: data) else {
            recentSearches = []
            return
        }
        recentSearches = searches
    }
    
    func addRecentSearch(_ searchTerm: String) {
        let trimmedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Don't add empty searches
        guard !trimmedSearchTerm.isEmpty else { return }
        
        let newSearch = RecentSearch(searchTerm: trimmedSearchTerm)
        
        // Remove existing search with same term (case insensitive)
        recentSearches.removeAll { $0 == newSearch }
        
        // Add to beginning
        recentSearches.insert(newSearch, at: 0)
        
        // Limit to max recent searches
        recentSearches = Array(recentSearches.prefix(maxSearches))
        
        // Save to UserDefaults
        saveRecentSearches()
    }
    
    private func saveRecentSearches() {
        guard let data = try? JSONEncoder().encode(recentSearches) else { return }
        userDefaults.set(data, forKey: key)
    }
    
    func clearRecentSearches() {
        recentSearches = []
        userDefaults.removeObject(forKey: key)
    }
}