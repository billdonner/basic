import SwiftUI
enum StateOfPlay : Int, Codable {
  case initializingApp
  case playingNow
  case justLost
  case justWon
  case justAbandoned 
}

struct IdentifiablePoint: Identifiable {
  internal init(row: Int, col: Int, status: ChaMan.ChallengeStatus? = nil) {
    self.row = row
    self.col = col
    self.status = status
  }
  
  let id = UUID()
  let row: Int
  let col: Int
  let status: ChaMan.ChallengeStatus?
}



// MARK: - Data Models


struct BasicTopic: Codable {
    public init(name: String, subject: String="", pic: String="", notes: String="", subtopics: [String]=[]) {
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
    public init(description: String, version: String, author: String, date: String, topics: [BasicTopic]) {
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
    public var topics: [BasicTopic]
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

enum ChallengeOutcomes: Codable {
  case playedCorrectly
  case playedIncorrectly
  case unplayed
  
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


enum ChallengeError: Error {
  case notfound
}

// these will be ungainly
// Result enum to handle allocation and deallocation outcomes
enum AllocationResult: Equatable {
  case success([Int])
  case error(AllocationError)
  
  enum AllocationError: Equatable, Error {
    static func ==(lhs: AllocationError, rhs: AllocationError) -> Bool {
      switch (lhs, rhs) {
      case (.emptyTopics, .emptyTopics):
        return true
      case (.invalidTopics(let lhsTopics), .invalidTopics(let rhsTopics)):
        return lhsTopics == rhsTopics
      case (.insufficientChallenges, .insufficientChallenges):
        return true
      default:
        return false
      }
    }
    case emptyTopics
    case invalidTopics([String])
    case invalidDeallocIndices([Int])
    case insufficientChallenges
  }
}
