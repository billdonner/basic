import SwiftUI

// Assuming a mock PlayData JSON file in the main bundle
let jsonFileName = "playdata.json"
let starting_size = 3 // Example size, can be 3 to 6
let starting_topics = ["Actors", "Animals","Cars"] // Example topics

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

// Loads the PlayData from a JSON file in the main bundle
func loadPlayData(from filename: String) throws -> PlayData {
    guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
        throw URLError(.fileDoesNotExist)
    }
    
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(PlayData.self, from: data)
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
struct TopBehaviorView:View {
  @EnvironmentObject var challengeManager: ChallengeManager
  @EnvironmentObject var appColors: AppColors
  @EnvironmentObject var gameBoard: GameBoard
  @State var chal :IdentifiablePoint? = nil
  @State var playCount = 0
  var body: some View {
    FrontView(size: starting_size, topics: starting_topics,playCount: $playCount){ row,col    in
      //tap behavior
      chal = IdentifiablePoint(row:row,col:col)
    }
    .onAppear {
      loadAllData(challengeManager: challengeManager,gameBoard:gameBoard)
       
      }
      .onDisappear {
        saveChallengeStatuses(challengeManager.challengeStatuses)
      }
      .sheet(item:$chal ) { cha in
        DetailChallengeView (row:cha.row,col:cha.col, playCount: $playCount)
          .environmentObject(appColors)
          .environmentObject(challengeManager)
        }
      }
  }
func loadAllData (challengeManager: ChallengeManager,gameBoard:GameBoard) {
  
  do {
    if  let gb =  gameBoard.loadGameBoard() {
      gameBoard.cellstate = gb.cellstate
      gameBoard.size = gb.size
      gameBoard.topics = gb.topics
      gameBoard.board = gb.board
      gameBoard.gimmees = gb.gimmees
    }
    try challengeManager.playData = loadPlayData(from: jsonFileName)
    if let playData = challengeManager.playData {
      if let loadedStatuses = loadChallengeStatuses() {
        challengeManager.challengeStatuses = loadedStatuses
      } else {
        let challenges = playData.gameDatum.flatMap { $0.challenges}
        var cs:[ChallengeStatus] = []
        for j in 0..<challenges.count {
          cs.append(ChallengeStatus(id:challenges[j].id,val:.inReserve))
        }
        challengeManager.challengeStatuses = cs
      }
    }
  } catch {
    print("Failed to load PlayData: \(error)")
  }
}

// The app's main entry point
@main
struct ChallengeGameApp: App {
  private var challengeManager = ChallengeManager()
  private var appColors = AppColors()
  private var gameBoard = GameBoard(size: 1, topics: ["Nuts"], challenges:[ Challenge.complexMock])
  var body: some Scene {
    WindowGroup {
      TopBehaviorView()
        .environmentObject(appColors)
        .environmentObject(challengeManager)
        .environmentObject(gameBoard)
    }
  }

  

  
}


