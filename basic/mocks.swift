//
//  mocks.swift
//  basic
//
//  Created by bill donner on 7/9/24.
//

import Foundation

extension PlayData {

  static let topic1 = Topic(name: "topic1", subject: "topic1", pic: "", notes: "notes", subtopics: [])
  static let topic2 = Topic(name: "topic2", subject: "topic2", pic: "", notes: "notes", subtopics: [])
  static let topic3 = Topic(name: "topic3", subject: "topic3", pic: "", notes: "notes", subtopics: [])
  static let topic4 = Topic(name: "topic4", subject: "topic4", pic: "", notes: "notes", subtopics: [])
  static var tg : TopicGroup =  TopicGroup(description: "Mock Topics",
                                           version:"1.0",
                                           author: "WLD",
                                           date: "\(Date.now)",
                                           topics: [topic1,topic2,topic3,topic4])
  
  static let gd1 : GameData = GameData(topic: "Fantasy Geography", challenges: Challenge.mockChallenges)
                                       
  static let mock = PlayData(topicData: tg, gameDatum: [gd1], playDataId: "id123", blendDate: Date.now, pic: nil)
}


extension GameBoard {

  static var mock = {
    GameBoard(size:3,topics:Array(MockTopics.mockTopics.prefix(5)),  challenges:Challenge.mockChallenges)
  }
}

extension Challenge {
  static var mockChallenges = [Challenge.complexMock,.amock,.complexMockWithFiveAnswers,
                      .complexMockWithThreeAnswers,.bmock,.cmock,
                      .dmock,.emock,.fmock]
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
    topic: "History",
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
    topic: "History",
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
    topic: "Science",
    hint: "This interpretation was proposed by Hugh Everett in 1957.",
    answers: ["Copenhagen Interpretation", "Many-Worlds Interpretation", "Pilot-Wave Theory"],
    correct: "Many-Worlds Interpretation",
    explanation: "The Many-Worlds Interpretation, proposed by Hugh Everett, suggests that all possible alternate histories and futures are real, each representing an actual 'world' or 'universe'. This means that every possible outcome of every event defines or exists in its own 'world'.",
    id: "UUID123456-ComplexMockWithThreeAnswers",
    date: Date.now,
    aisource: "Advanced Quantum Theory",
    notes: "This question delves into interpretations of quantum mechanics, particularly the philosophical implications of quantum events and their outcomes."
  )
  static let bmock = Challenge(
      question: "Which ancient city is known for its hanging gardens, one of the Seven Wonders of the Ancient World?",
      topic: "History",
      hint: "This city was located in modern-day Iraq and is often associated with King Nebuchadnezzar II.",
      answers: ["Babylon", "Athens", "Rome", "Carthage"],
      correct: "Babylon",
      explanation: "Babylon is famous for its Hanging Gardens, which were considered one of the Seven Wonders of the Ancient World, though their existence is debated.",
      id: "UUID320240-History",
      date: Date.now,
      aisource: "Historical Archives AI",
      notes: "This question explores knowledge of ancient civilizations and their landmarks."
  )

  static let cmock = Challenge(
      question: "In the famous novel 'Moby Dick', what is the name of the ship captained by Ahab?",
      topic: "Literature",
      hint: "The ship's name starts with 'P' and is central to the storyline.",
      answers: ["Pequod", "Nautilus", "Endeavour", "Beagle"],
      correct: "Pequod",
      explanation: "The Pequod is the whaling ship commanded by Captain Ahab in Herman Melville's classic novel 'Moby Dick'.",
      id: "UUID320241-Literature",
      date: Date.now,
      aisource: "Literary Genius AI",
      notes: "This question is designed for literature enthusiasts familiar with classic novels."
  )

  static let dmock = Challenge(
      question: "What is the primary ingredient in the traditional Japanese dish 'sushi'?",
      topic: "Cuisine",
      hint: "This ingredient is a staple food in many Asian countries.",
      answers: ["Rice", "Fish", "Seaweed", "Tofu"],
      correct: "Rice",
      explanation: "Rice is the main ingredient in sushi, often combined with seafood and vegetables.",
      id: "UUID320242-Cuisine",
      date: Date.now,
      aisource: "Culinary Insights AI",
      notes: "This question tests basic knowledge of traditional Japanese cuisine."
  )

  static let emock = Challenge(
      question: "What is the process by which plants convert sunlight into chemical energy?",
      topic: "Science",
      hint: "This process involves chlorophyll and produces oxygen as a byproduct.",
      answers: ["Photosynthesis", "Respiration", "Transpiration", "Fermentation"],
      correct: "Photosynthesis",
      explanation: "Photosynthesis is the process by which plants use sunlight to synthesize foods with the help of chlorophyll.",
      id: "UUID320243-Biology",
      date: Date.now,
      aisource: "Biological Systems AI",
      notes: "This question is fundamental for students studying plant biology."
  )

  static let fmock = Challenge(
      question: "In computer science, what does 'CPU' stand for?",
      topic: "Science",
      hint: "It's the main part of a computer responsible for interpreting instructions.",
      answers: ["Central Processing Unit", "Control Power Unit", "Central Program Unit", "Computer Processing Unit"],
      correct: "Central Processing Unit",
      explanation: "CPU stands for Central Processing Unit, which is the primary component of a computer that performs most of the processing inside.",
      id: "UUID320244-Technology",
      date: Date.now,
      aisource: "Tech Education AI",
      notes: "This question assesses basic knowledge of computer components."
  )

  static let gmock = Challenge(
      question: "Which planet is known as the 'Red Planet'?",
      topic: "Science",
      hint: "This planet is the fourth from the sun and has a reddish appearance.",
      answers: ["Mars", "Venus", "Jupiter", "Saturn"],
      correct: "Mars",
      explanation: "Mars is often called the 'Red Planet' due to its reddish color caused by iron oxide on its surface.",
      id: "UUID320245-Astronomy",
      date: Date.now,
      aisource: "Space Exploration AI",
      notes: "This question is suitable for beginners in astronomy."
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
