//
//  StringExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import Foundation

extension String {
    func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
    
    func stripLineBreaks() -> String {
        return self.replacingOccurrences(of: "\n", with: " ")
    }
    
    func humanReadable() -> String {
        let indexes = Set(self
            .enumerated()
            .filter { $0.element.isUppercase }
            .map { $0.offset })
        
        let chunks = self
            .map { String($0) }
            .enumerated()
            .reduce([String]()) { chunks, elm -> [String] in
                guard !chunks.isEmpty else { return [elm.element.uppercased()] }
                guard !indexes.contains(elm.offset) else { return chunks + [String(elm.element)] }

                var chunks = chunks
                chunks[chunks.count-1] += String(elm.element)
                return chunks
            }
        
        return chunks.joined(separator: " ")
    }
}
