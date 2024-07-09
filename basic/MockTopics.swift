//
//  MockTopics.swift
//  tpicker3
//
//  Created by bill donner on 7/8/24.
//

import Foundation
// All available topics
let mockTopics = [
    "Science", "Technology", "Engineering", "Mathematics",
    "History", "Geography", "Art", "Literature",
    "Music", "Philosophy", "Sports", "Nature",
    "Politics", "Economics", "Culture", "Health",
    "Education", "Language", "Religion", "Society",
    "Psychology", "Law", "Media", "Environment",
    "Space", "Travel", "Food", "Fashion",
    "Movies", "Games", "Animals", "Plants",
    "Computers", "Robotics", "AI", "Software",
    "Hardware", "Networking", "Data", "Security",
    "Biology", "Chemistry", "Physics", "Astronomy",
    "Geology", "Meteorology", "Oceanography", "Ecology"
]
/// Provider for generating and saving topics.
class MockTopicProvider {
  static let shared = MockTopicProvider()
  private let topicsKey = "selectedTopics"
  private let schemeIndexKey = "selectedSchemeIndex"
  private init() {}

  /// Returns a specified number of random topics from a provided list.
  func getRandomTopics(_ count: Int, from topics: [String]) -> [String] {
      return Array(topics.shuffled().prefix(count))
  }

  /// Loads topics from UserDefaults.
  func loadTopics() -> [String] {
      return UserDefaults.standard.stringArray(forKey: topicsKey) ?? []
  }

  /// Saves topics to UserDefaults.
  func saveTopics(_ topics: [String]) {
      UserDefaults.standard.setValue(topics, forKey: topicsKey)
  }

  /// Loads the color scheme index from UserDefaults.
  func loadSchemeIndex() -> Int {
      return UserDefaults.standard.integer(forKey: schemeIndexKey)
  }

  /// Saves the color scheme index to UserDefaults.
  func saveSchemeIndex(_ index: Int) {
      UserDefaults.standard.setValue(index, forKey: schemeIndexKey)
  }
}
