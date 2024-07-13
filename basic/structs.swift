import SwiftUI
enum GameState : Int, Codable {
  case initializingApp
  case playingNow
  case justLost
  case justWon
  case justAbandoned 
}

struct IdentifiablePoint: Identifiable {
  let id = UUID()
  let row: Int
  let col: Int
}



// MARK: - Data Models


struct Topic: Codable {
    public init(name: String, subject: String, pic: String, notes: String, subtopics: [String]) {
        self.name = name
        self.subject = subject
        self.pic = pic
        self.notes = notes
        self.subtopics = subtopics
    }
    
    public var name: String
    public var subject: String
    public var pic: String
    public var notes: String
    public var subtopics: [String]
}

struct TopicGroup: Codable {
    public init(description: String, version: String, author: String, date: String, topics: [Topic]) {
        self.description = description
        self.version = version
        self.author = author
        self.date = date
        self.topics = topics
    }
    
    public var description: String
    public var version: String
    public var author: String
    public var date: String
    public var topics: [Topic]
}

struct GameData: Codable, Hashable, Identifiable, Equatable {
    public init(topic: String, challenges: [Challenge], pic: String? = "leaf", shuffle: Bool = false, commentary: String? = nil) {
        self.topic = topic
        self.challenges = shuffle ? challenges.shuffled() : challenges
        self.id = UUID().uuidString
        self.generated = Date()
        self.pic = pic
        self.commentary = commentary
    }
    
    public let id: String
    public let topic: String
    public let challenges: [Challenge]
    public let generated: Date
    public let pic: String?
    public let commentary: String?
}

struct PlayData: Codable {
    public init(topicData: TopicGroup, gameDatum: [GameData], playDataId: String, blendDate: Date, pic: String? = nil) {
        self.topicData = topicData
        self.gameDatum = gameDatum
        self.playDataId = playDataId
        self.blendDate = blendDate
        self.pic = pic
    }
    
    public let topicData: TopicGroup
    public let gameDatum: [GameData]
    public let playDataId: String
    public let blendDate: Date
    public let pic: String?
  
  var allTopics : [String] {
    self.topicData.topics.map {$0.name}
  }
}

// MARK: - Enums
// these will be small and fast for all the math done on the matrices

// these will be ungainly
enum ChallengeStatusVal : Int, Codable  {
  case inReserve         // 0
  case allocated         // 1
  case playedCorrectly   // 2
  case playedIncorrectly // 3
  case abandoned         // 4
  
  func describe () -> String {
    switch self {
    case .inReserve : return "RR"
    case .allocated : return "AA"
    case .playedCorrectly: return "CC"
    case .playedIncorrectly: return "XX"
    case .abandoned: return "ZZ"
    }
  }
}

struct ChallengeStatus: Codable,Equatable {
  var id: String
  var val: ChallengeStatusVal
}
 




// Get the file path for storing challenge statuses
func getChallengeStatusesFilePath() -> URL {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for:.documentDirectory, in: .userDomainMask)
    return urls[0].appendingPathComponent("challengeStatuses.json")
}
// Get the file path for storing challenge statuses
func getGameBoardFilePath() -> URL {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for:.documentDirectory, in: .userDomainMask)
    return urls[0].appendingPathComponent("gameBoard.json")
}

// Save the challenge statuses to a file
func saveChallengeStatuses(_ statuses: [ChallengeStatus]) {
    let filePath = getChallengeStatusesFilePath()
    do {
        let data = try JSONEncoder().encode(statuses)
        try data.write(to: filePath)
    } catch {
        print("Failed to save challenge statuses: \(error)")
    }
}

// Load the challenge statuses from a file
func loadChallengeStatuses() -> [ChallengeStatus]? {
    let filePath = getChallengeStatusesFilePath()
    do {
        let data = try Data(contentsOf: filePath)
        let statuses = try JSONDecoder().decode([ChallengeStatus].self, from: data)
        return statuses
    } catch {
        print("Failed to load challenge statuses: \(error)")
        return nil
    }
}
// Assuming a mock PlayData JSON file in the main bundle

/*
 
 ### Explanation
 1. **GameBoard Class**:
 - The `GameBoard` class is initialized with a size and an array of topics.
 - It has methods to populate the board with challenges, reset the board, replace a challenge, and get unplayed challenges.

/////////////
 
 */
enum ChallengeOutcomes: Codable {
  case playedCorrectly, playedIncorrectly, unplayed
  
  var borderColor: Color {
    switch self {
    case .playedCorrectly: return .green
    case .playedIncorrectly: return .red
    case .unplayed: return .gray
    }
  }
}

struct Challenge: Codable, Equatable, Hashable, Identifiable {
  public let question: String
  public let topic: String
  public let hint: String
  public let answers: [String]
  public let correct: String
  public let explanation: String?
  public let id: String
  public let date: Date
  public let aisource: String
  public let notes: String?
  
  public init(question: String, topic: String, hint: String, answers: [String], correct: String, explanation: String? = nil, id: String, date: Date, aisource: String, notes: String? = nil) {
    self.question = question
    self.topic = topic
    self.hint = hint
    self.answers = answers
    self.correct = correct
    self.explanation = explanation
    self.id = id
    self.date = date
    self.aisource = aisource
    self.notes = notes
  }
}

