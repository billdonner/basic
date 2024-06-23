import SwiftUI

// Assuming a mock PlayData JSON file in the main bundle
let jsonFileName = "playdata.json"
let starting_size = 6 // Example size, can be 3 to 6
let starting_topics = ["Actors", "Animals","Cars"] // Example topics

struct IdentifiablePoint: Identifiable {
  let id = UUID()
  let row: Int
  let col: Int
}



// MARK: - Data Models

struct Challenge: Codable, Equatable, Hashable, Identifiable {
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
    
    public static func decodeArrayFrom(data: Data) throws -> [Challenge] {
        try JSONDecoder().decode([Challenge].self, from: data)
    }
    public static func decodeFrom(data: Data) throws -> Challenge {
        try JSONDecoder().decode(Challenge.self, from: data)
    }
}

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

enum ChallengeStatus: Int, Codable {
    case inReserve         // 0
    case allocated         // 1
    case playedCorrectly   // 2
    case playedIncorrectly // 3
    case abandoned         // 4
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
 
 2. **ChallengeManager Enhancements**:
 - Added methods to allocate and return challenges, ensuring detailed error handling.
 
 3. **TestView**:
 - Displays the game board using a `ScrollView` and nested `HStack` and `VStack`.
 - Each cell is sized to 120x120 pixels with 2 pixels of padding.
 - The border color is green if the challenge is played correctly and red if played incorrectly.
 - A test function `randomlyMarkCells` randomly marks 1/3 of the cells as correct and 1/2 as incorrect.
 
/////////////
 
 */


// The app's main entry point
@main
struct ChallengeGameApp: App {
  private var challengeManager = ChallengeManager()
  private var appColors = AppColors()
  @State var tapped :IdentifiablePoint? = nil
  
  var body: some Scene {
    WindowGroup {
      TestView(size: starting_size, topics: starting_topics){ row, col in
        print("tapped \(row) \(col)")
        tapped=IdentifiablePoint(row: row,col: col)
      } 
        .environmentObject(appColors)
        .environmentObject(challengeManager)
        .onAppear {
          do {
            try challengeManager.playData = loadPlayData(from: jsonFileName)
            if let playData = challengeManager.playData {
              if let loadedStatuses = loadChallengeStatuses() {
                challengeManager.challengeStatuses = loadedStatuses
              } else {
                challengeManager.challengeStatuses = [ChallengeStatus](repeating: .inReserve, count: playData.gameDatum.flatMap { $0.challenges }.count)
              }
            }
          } catch {
            print("Failed to load PlayData: \(error)")
          }
        }
        .onDisappear {
          saveChallengeStatuses(challengeManager.challengeStatuses)
        }
        .sheet(item:$tapped) { tapped in
         
          if  let ch = challengeManager.getChallenge(row:tapped.row,col:tapped.col) {
            PlayChallengeView (ch: ch)
          }
          else{
            Color.red
          }
          
        }
    }
  }
}



// MARK: - ColorScheme

fileprivate extension Color {
#if os(macOS)
  typealias SystemColor = NSColor
#else
  typealias SystemColor = UIColor
#endif
  
  var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    
#if os(macOS)
    SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
    // Note that non RGB color will raise an exception, that I don't now how to catch because it is an Objc exception.
#else
    guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
      // Pay attention that the color should be convertible into RGB format
      // Colors using hue, saturation and brightness won't work
      return nil
    }
#endif
    
    return (r, g, b, a)
  }
}

extension Color: Codable {
  enum CodingKeys: String, CodingKey {
    case red, green, blue
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let r = try container.decode(Double.self, forKey: .red)
    let g = try container.decode(Double.self, forKey: .green)
    let b = try container.decode(Double.self, forKey: .blue)
    
    self.init(red: r, green: g, blue: b)
  }
  
  public func encode(to encoder: Encoder) throws {
    guard let colorComponents = self.colorComponents else {
      return
    }
    
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(colorComponents.red, forKey: .red)
    try container.encode(colorComponents.green, forKey: .green)
    try container.encode(colorComponents.blue, forKey: .blue)
  }
}

struct TopicCountsView: View {
  let topic:Topic
  @EnvironmentObject var appColors: AppColors
  @EnvironmentObject var challengeManager: ChallengeManager
  var body: some View {
    HStack {
      RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
        .frame(width: 24)
        .padding()
        .foregroundColor(AppColors.colorFor(topic: topic.name)?.backgroundColor)
      Text(topic.name)
      Spacer()
      Text("\(challengeManager.allocatedChallengesCount(for: topic)) - "
           + "\(challengeManager.freeChallengesCount(for: topic)) - "
           + "\(challengeManager.abandonedChallengesCount(for: topic))")
    }
    .padding(.horizontal)
  }
}
