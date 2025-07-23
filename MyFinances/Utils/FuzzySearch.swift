//
//  FuzzySearch.swift
//  MyFinances
//
//  Created by Артём on 05.07.2025.
//

import Foundation

// MARK: - Логика ленивого поиска
struct FuzzySearch {
    static func search(_ pattern: String, in collection: [String]) -> [String] {
        let lowercasedPattern = pattern.lowercased()
        let dynamicMaxDistance = max(1, min(2, lowercasedPattern.count / 3))
        return collection
            .map { item -> (String, Bool, Int) in
                let lowerItem = item.lowercased()
                let contains = lowerItem.contains(lowercasedPattern)
                let distance = Self.levenshteinDistance(between: lowercasedPattern, and: lowerItem)
                return (item, contains, distance)
            }
            .filter { $0.1 || $0.2 <= dynamicMaxDistance }
            .sorted {
                if $0.1 != $1.1 { return $0.1 } // сначала те, где contains == true
                return $0.2 < $1.2 // потом по расстоянию
            }
            .map(\.0)
    }

    private static func levenshteinDistance(between a: String, and b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        let aCount = aChars.count
        let bCount = bChars.count
        var dp = Array(repeating: Array(repeating: 0, count: bCount + 1), count: aCount + 1)
        for i in 0...aCount { dp[i][0] = i }
        for j in 0...bCount { dp[0][j] = j }
        for i in 1...aCount {
            for j in 1...bCount {
                if aChars[i - 1] == bChars[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = min(
                        dp[i - 1][j] + 1,
                        dp[i][j - 1] + 1,
                        dp[i - 1][j - 1] + 1
                    )
                }
            }
        }
        return dp[aCount][bCount]
    }
}
