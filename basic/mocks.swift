//
//  mocks.swift
//  basic
//
//  Created by bill donner on 7/9/24.
//

import Foundation
extension GameBoard {
  static var mock = {
    GameBoard(size:1,topics:["Fun"],challenges:[Challenge.complexMock,.amock])
  }
}

extension Challenge {
  static let amock = Challenge(
    question: "What is the capital of the fictional land where dragons and wizards are commonplace?",
    topic: "Fantasy Geography",
    hint: "This land is featured in many epic tales, often depicted with castles and magical forests.",
    answers: ["Eldoria", "Mysticore", "Dragontown", "Wizardville"],
    correct: "Mysticore",
    explanation: "Mysticore is the capital of the mystical realm in the series 'Chronicles of the Enchanted Lands', known for its grand castle surrounded by floating islands.",
    id: "UUID320239-MoreComplex",
    date: Date.now,
    aisource: "Advanced AI Conjecture",
    notes: "This question tests knowledge of fictional geography and is intended for advanced level quiz participants in the fantasy genre."
  )
 
  static let complexMock = Challenge(
    question: "What controversial statement did Kellyanne Conway make regarding 'alternative facts' during her tenure as Counselor to the President?",
    topic: "Political History",
    hint: "This statement was made in defense of false claims about the crowd size at the 2017 Presidential Inauguration.",
    answers: ["She claimed it was a joke.", "She denied making the statement.", "She referred to it as 'alternative facts'.", "She blamed the media for misquoting her."],
    correct: "She referred to it as 'alternative facts'.",
    explanation: "Kellyanne Conway used the term 'alternative facts' during a Meet the Press interview on January 22, 2017, to defend White House Press Secretary Sean Spicer's false statements about the crowd size at Donald Trump's inauguration. This phrase quickly became infamous and was widely criticized.",
    id: "UUID123456-ComplexMock",
    date: Date.now,
    aisource: "Historical Documentation",
    notes: "This question addresses a notable moment in modern political discourse and examines the concept of truth in media and politics."
  )
 
  static let complexMockWithFiveAnswers = Challenge(
    question: "Which of the following statements about Abraham Lincoln is NOT true?",
    topic: "American History",
    hint: "This statement involves a significant policy change during Lincoln's presidency.",
    answers: [
      "Abraham Lincoln issued the Emancipation Proclamation in 1863.",
      "Lincoln delivered the Gettysburg Address in 1863.",
      "Abraham Lincoln was the first U.S. president to be assassinated.",
      "Lincoln signed the Homestead Act in 1862.",
      "Lincoln served two terms as President of the United States."
    ],
    correct: "Lincoln served two terms as President of the United States.",
    explanation: """
        Abraham Lincoln did not serve two full terms as President. He was re-elected in 1864 but was assassinated by John Wilkes Booth on April 14, 1865, just a little over a month into his second term. Lincoln's first term was from March 4, 1861, to March 4, 1865, and he was re-elected for a second term in March 1865. He issued the Emancipation Proclamation on January 1, 1863, delivered the Gettysburg Address on November 19, 1863, and signed the Homestead Act into law on May 20, 1862.
        """,
    id: "UUID123456-ComplexMockWithFiveAnswers",
    date: Date.now,
    aisource: "Historical Documentation",
    notes: "This question tests detailed knowledge of key events and facts about Abraham Lincoln's presidency."
  )
 
  static let complexMockWithThreeAnswers = Challenge(
    question: "In the context of quantum mechanics, which of the following interpretations suggests that every possible outcome of a quantum event exists in its own separate universe?",
    topic: "Quantum Mechanics",
    hint: "This interpretation was proposed by Hugh Everett in 1957.",
    answers: ["Copenhagen Interpretation", "Many-Worlds Interpretation", "Pilot-Wave Theory"],
    correct: "Many-Worlds Interpretation",
    explanation: "The Many-Worlds Interpretation, proposed by Hugh Everett, suggests that all possible alternate histories and futures are real, each representing an actual 'world' or 'universe'. This means that every possible outcome of every event defines or exists in its own 'world'.",
    id: "UUID123456-ComplexMockWithThreeAnswers",
    date: Date.now,
    aisource: "Advanced Quantum Theory",
    notes: "This question delves into interpretations of quantum mechanics, particularly the philosophical implications of quantum events and their outcomes."
  )
}
class MockTopics {
static let mockTopics = [
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
  static let shared = MockTopics()
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
