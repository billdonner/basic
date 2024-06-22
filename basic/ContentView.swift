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

struct ColorScheme: Codable {
    let topic: String
    let foregroundColor: Color
    let backgroundColor: Color
    
    init(topic: String, foregroundColor: Color, backgroundColor: Color) {
        self.topic = topic
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
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
// MARK: - Modified GameBoard Class

class GameBoard {
    var board: [[Challenge]]
    var status: [[ChallengeStatus]]
    var size: Int
    var topics: [String]
    var colorSchemes: [String: ColorScheme]
    
    init(size: Int, topics: [String], challenges: [Challenge], colorSchemes: [String: ColorScheme]) {
        self.size = size
        self.topics = topics
        self.colorSchemes = colorSchemes
        self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: size), count: size)
        self.status = Array(repeating: Array(repeating: .inReserve, count: size), count: size)
        populateBoard(with: challenges)
    }
    
    func populateBoard(with challenges: [Challenge]) {
        var challengeIndex = 0
        for row in 0..<size {
            for col in 0..<size {
                if challengeIndex < challenges.count {
                    board[row][col] = challenges[challengeIndex]
                    status[row][col] = .allocated
                    challengeIndex += 1
                }
            }
        }
    }
    
    func resetBoard() -> [Challenge] {
        var unplayedChallenges: [Challenge] = []
        for row in 0..<size {
            for col in 0..<size {
                if status[row][col] == .allocated {
                    unplayedChallenges.append(board[row][col])
                    status[row][col] = .inReserve
                }
            }
        }
        return unplayedChallenges
    }
    
    func replaceChallenge(at position: (Int, Int), with newChallenge: Challenge) {
        let (row, col) = position
        if row >= 0 && row < size && col >= 0 && col < size {
            status[row][col] = .abandoned
            board[row][col] = newChallenge
            status[row][col] = .allocated
        }
    }
    
    func getUnplayedChallenges() -> [Challenge] {
        var unplayedChallenges: [Challenge] = []
        for row in 0..<size {
            for col in 0..<size {
                if status[row][col] == .allocated {
                    unplayedChallenges.append(board[row][col])
                }
            }
        }
        return unplayedChallenges
    }
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

// The manager class to handle Challenge-related operations and state
@Observable
class ChallengeManager : ObservableObject {
    internal init(playData: PlayData? = nil) {
        self.playData = playData
        if let playData = playData {
            self.challengeStatuses = [ChallengeStatus](repeating: .inReserve, count: playData.gameDatum.flatMap { $0.challenges }.count)
        } else {
            self.challengeStatuses = []
        }
    }
    
    var playData: PlayData?
    var challengeStatuses: [ChallengeStatus]  // Using array instead of dictionary
    
    func resetChallengeStatuses(at challengeIndices: [Int]) {
        for index in challengeIndices {
            if index >= 0 && index < challengeStatuses.count {
                challengeStatuses[index] = .inReserve
            }
        }
    }
    func resetAllChallengeStatuses() {
        if let playData = playData {
            self.challengeStatuses = [ChallengeStatus](repeating: .inReserve, count: playData.gameDatum.flatMap { $0.challenges }.count)
        } else {
            self.challengeStatuses = []
        }
    }
    // Extracts all challenges from PlayData
    func getAllChallenges() -> [Challenge] {
        guard let playData = playData else { return [] }
        return playData.gameDatum.flatMap { $0.challenges }
    }
    
    // Allocates N challenges from all challenges
    func allocateChallenges(_ n: Int) -> [Challenge]? {
        let allChallenges = getAllChallenges()
        var allocatedChallenges: [Challenge] = []
        var allocatedCount = 0
        for index in 0..<allChallenges.count {
            if challengeStatuses[index] == .inReserve {
                challengeStatuses[index] = .allocated
                allocatedChallenges.append(allChallenges[index])
                allocatedCount += 1
                if allocatedCount == n { break }
            }
        }
        return allocatedCount == n ? allocatedChallenges : nil
    }
    
    // Allocates N challenges where the topic is specified
    func allocateChallenges(for topic: String, count n: Int) -> [Challenge]? {
        defer {
            saveChallengeStatuses(challengeStatuses)
        }
        let allChallenges = getAllChallenges()
        var allocatedChallenges: [Challenge] = []
        var allocatedCount = 0
        for index in 0..<allChallenges.count {
            if allChallenges[index].topic == topic && challengeStatuses[index] == .inReserve {
                challengeStatuses[index] = .allocated
                allocatedChallenges.append(allChallenges[index])
                allocatedCount += 1
                if allocatedCount == n { break }
            }
        }
        return allocatedCount == n ? allocatedChallenges : nil
    }
    
    // Allocates N challenges nearly evenly from specified topics, taking from any topic in the list if needed
    func allocateChallenges(forTopics topics: [String], count n: Int) -> [Challenge]? {
        let allChallenges = getAllChallenges()
        var topicChallengeMap: [String: [Int]] = [:]
        var allocatedChallenges: [Challenge] = []
        var allocatedCount = 0
        defer {
            saveChallengeStatuses(challengeStatuses)
        }
        // Initialize the topicChallengeMap
        for (index, challenge) in allChallenges.enumerated() {
            if topics.contains(challenge.topic) && challengeStatuses[index] == .inReserve {
                topicChallengeMap[challenge.topic, default: []].append(index)
            }
        }
        
        // Calculate how many challenges to allocate per topic initially
        let challengesPerTopicInitial = n / topics.count
        
        
        // Check if all topics together have enough challenges
        let totalAvailableChallenges = topics.flatMap { topicChallengeMap[$0] ?? [] }.count
        guard totalAvailableChallenges >= n else {
            return nil
        }
        
        // Allocate challenges from each topic nearly evenly
        for topic in topics {
            let availableChallenges = topicChallengeMap[topic] ?? []
            let challengesToAllocate = min(challengesPerTopicInitial, availableChallenges.count)
            for index in availableChallenges.prefix(challengesToAllocate) {
                challengeStatuses[index] = .allocated
                allocatedChallenges.append(allChallenges[index])
                allocatedCount += 1
            }
        }
        
        // Allocate any remaining challenges, taking from any available topics
        if allocatedCount < n {
            let additionalChallengesNeeded = n - allocatedCount
            let remainingAvailableChallenges = topics.flatMap { topicChallengeMap[$0] ?? [] }
            for index in remainingAvailableChallenges.prefix(additionalChallengesNeeded) {
                challengeStatuses[index] = .allocated
                allocatedChallenges.append(allChallenges[index])
                allocatedCount += 1
            }
        }
        
        return allocatedCount == n ? allocatedChallenges : nil
    }
    // get challenge at index
  func getChallenge(at index: Int) -> Challenge? {
    guard index >= 0 && index < getAllChallenges().count else { return nil }
    return getAllChallenges()[index]
  }
  
    // Replaces one challenge with another, marking the old one as abandoned
    func replaceChallenge(at index: Int) -> Challenge? {
        guard index >= 0 && index < getAllChallenges().count else { return nil }
        defer {
            saveChallengeStatuses(challengeStatuses)
        }
        // Mark the old challenge as abandoned
        challengeStatuses[index] = .abandoned
        
        // Allocate a new challenge from the same topic
        let topic = getAllChallenges()[index].topic
        let topicChallenges = getAllChallenges().enumerated().filter { $0.element.topic == topic && challengeStatuses[$0.offset] == .inReserve }
        
        guard let newChallengeIndex = topicChallenges.first?.offset else {
            return nil
        }
        
        challengeStatuses[newChallengeIndex] = .allocated
        return getAllChallenges()[newChallengeIndex]
    }
    
    // Replaces the last topic allocated
    func replaceLastAllocatedTopic() -> Challenge? {
        // Get the index of the last allocated challenge
        guard let lastAllocatedIndex = challengeStatuses.lastIndex(of: .allocated) else {
            return nil
        }
        
        // Replace the last allocated challenge
        return replaceChallenge(at: lastAllocatedIndex)
    }
    
    // Helper functions to get counts
    func allocatedChallengesCount(for topic: Topic) -> Int {
        return countChallenges(for: topic, with: .allocated)
    }
    
    func abandonedChallengesCount(for topic: Topic) -> Int {
        return countChallenges(for: topic, with: .abandoned)
    }
    
    func freeChallengesCount(for topic: Topic) -> Int {
        return getAllChallenges().enumerated().filter { $0.element.topic == topic.name && challengeStatuses[$0.offset] == .inReserve }.count
    }
    
    func countChallenges(for topic: Topic, with status: ChallengeStatus) -> Int {
        let allChallenges = getAllChallenges()
        return allChallenges.enumerated().filter { index, challenge in
            index < challengeStatuses.count && challenge.topic == topic.name && challengeStatuses[index] == status
        }.count
    }
}

// MARK: - TestView and Preview
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
 
 4. **Preview**
 */
// MARK: - Modified TestView

struct TestView: View {
    let size: Int
    let topics: [String]
    let tapGesture: (_ row: Int, _ col: Int) -> Void
    
    @EnvironmentObject var challengeManager: ChallengeManager
    @State private var gameBoard: GameBoard?
    @State private var colorSchemes: [String: ColorScheme] = [
        "Actors": ColorScheme(topic: "Actors", foregroundColor: .white, backgroundColor: .blue),
        "Animals": ColorScheme(topic: "Animals", foregroundColor: .black, backgroundColor: .green),
        "Cars": ColorScheme(topic: "Cars", foregroundColor: .yellow, backgroundColor: .indigo)
    ]
    @State private var hideCellContent = true
    private let spacing: CGFloat = 5
    // Adding a shrink factor to slightly reduce the cell size
    private let shrinkFactor: CGFloat = 0.9
    
    fileprivate func makeOneCell(_ row: Int, _ col: Int, gameBoard: GameBoard, cellSize: CGFloat) -> some View {
        return VStack {
            Text(hideCellContent ? " " : gameBoard.board[row][col].question)
                .padding(8)
                .frame(width: cellSize, height: cellSize)
                .background(colorSchemes[gameBoard.board[row][col].topic]?.backgroundColor ?? Color.gray)
                .foregroundColor(colorSchemes[gameBoard.board[row][col].topic]?.foregroundColor ?? Color.white)
                .border(borderColor(for: gameBoard.status[row][col]), width: 8)
                .cornerRadius(8)
                .onTapGesture {
                    tapGesture(row, col)
                }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    startNewGame(size: size, topics: topics)
                    hideCellContent = false
                }) {
                    Text("Start Game")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!hideCellContent)
                .opacity(hideCellContent ? 1 : 0.5)
                
                Button(action: {
                    endGame()
                    hideCellContent = true
                }) {
                    Text("End Game")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(hideCellContent)
                .opacity(!hideCellContent ? 1 : 0.5)
                
                Button(action: {
                    challengeManager.resetAllChallengeStatuses()
                    hideCellContent = true
                    clearAllCells()
                }) {
                    Text("Full Reset")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!hideCellContent)
                .opacity(hideCellContent ? 1 : 0.5)
            }
            .padding()
            
            if let gameBoard = gameBoard {
                GeometryReader { geometry in
                    let totalSpacing = spacing * CGFloat(gameBoard.size - 1)
                    let axisSize = min(geometry.size.width, geometry.size.height) - totalSpacing
                    let cellSize = (axisSize / CGFloat(gameBoard.size)) * shrinkFactor  // Apply shrink factor
                    
//                    ScrollView([.horizontal, .vertical]) {
                  VStack(alignment:.center, spacing: spacing) {
                            ForEach(0..<gameBoard.size, id: \.self) { row in
                                HStack(spacing: spacing) {
                                    ForEach(0..<gameBoard.size, id: \.self) { col in
                                        makeOneCell(row, col, gameBoard: gameBoard, cellSize: cellSize)
                                    }
                                }
                            }
                        }
                    .padding()
              }
            } else {
                Text("Loading...")
                    .onAppear {
                        startNewGame(size: size, topics: topics)
                    }
            }
            Spacer()
            Divider()
            VStack {
                HStack {
                    Text("Allocated: \(allocatedChallengesCount())")
                    Text("Free: \(freeChallengesCount())")
                    // Text("PlayingNow: \(playingNow)")
                }
                AllocatorView(colorSchemes: colorSchemes)
                
            }.frame(height: 150)
            
        }
    }
    
    func startNewGame(size: Int, topics: [String]) {
        if let challenges = challengeManager.allocateChallenges(forTopics: topics, count: size * size) {
            gameBoard = GameBoard(size: size, topics: topics, challenges: challenges, colorSchemes: colorSchemes)
            randomlyMarkCells()
        } else {
            print("Failed to allocate challenges for the game board.")
        }
    }
    
    func endGame() {
        if let gameBoard = gameBoard {
            let unplayedChallenges = gameBoard.resetBoard()
            challengeManager.resetChallengeStatuses(at: unplayedChallenges.map { challengeManager.getAllChallenges().firstIndex(of: $0)! })
        }
    }
    
    func clearAllCells() {
        guard let gameBoard = gameBoard else { return }
        for row in 0..<gameBoard.size {
            for col in 0..<gameBoard.size {
                gameBoard.status[row][col] = .inReserve
            }
        }
    }
    
    func randomlyMarkCells() {
        guard let gameBoard = gameBoard else { return }
        let totalCells = gameBoard.size * gameBoard.size
        let correctCount = totalCells / 3
        let incorrectCount = totalCells / 2
        
        var correctMarked = 0
        var incorrectMarked = 0
        
        for row in 0..<gameBoard.size {
            for col in 0..<gameBoard.size {
                if correctMarked < correctCount {
                    gameBoard.status[row][col] = .playedCorrectly
                    correctMarked += 1
                } else if incorrectMarked < incorrectCount {
                    gameBoard.status[row][col] = .playedIncorrectly
                    incorrectMarked += 1
                } else {
                    gameBoard.status[row][col] = .allocated
                }
            }
        }
    }
    
    func borderColor(for status: ChallengeStatus) -> Color {
        switch status {
        case .playedCorrectly:
            return .green
        case .playedIncorrectly:
            return .red
        default:
            return .clear
        }
    }
    
    func allocatedChallengesCount() -> Int {
        return challengeManager.challengeStatuses.filter { $0 == .allocated }.count
    }
    
    func freeChallengesCount() -> Int {
        return challengeManager.challengeStatuses.filter { $0 == .inReserve }.count
    }
}

// Preview Provider for SwiftUI preview
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach([3, 4, 5, 6], id: \.self) { size in
                TestView(
                    size: size,
                    topics: ["Actors", "Animals", "Cars"],
                    tapGesture: { row, col in
                        print("Tapped cell at row \(row), col \(col)")
                    }
                )
                .environmentObject(ChallengeManager())  // Ensure to add your ChallengeManager
                .previewLayout(.fixed(width: 300, height: 300))
                .previewDisplayName("Size \(size)x\(size)")
            }
        }
    }
}


func colorOf(topic:String, in dict:[String:ColorScheme])->Color {
  guard let z = dict[topic] else {return .black}
  return z.backgroundColor
}
/////////////
struct AllocatorView: View {
    let colorSchemes: [String: ColorScheme]
    @EnvironmentObject var challengeManager: ChallengeManager
    @Environment(\.colorScheme) var colorScheme
    @State var succ = false

    var body: some View {
        Group {
            if let playData = challengeManager.playData {
                ScrollView {
                    ForEach(playData.topicData.topics, id: \.name) { topic in
                        if challengeManager.allocatedChallengesCount(for: topic) > 0 {
                            HStack {
                                RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
                                    .frame(width: 24)
                                    .padding()
                                    .foregroundColor(colorOf(topic: topic.name, in: colorSchemes))
                                Text(topic.name)
                                Spacer()
                                Text("\(challengeManager.allocatedChallengesCount(for: topic)) - "
                                   + "\(challengeManager.freeChallengesCount(for: topic)) - "
                                   + "\(challengeManager.abandonedChallengesCount(for: topic))")
                            }
                            .padding(.horizontal)
                            .foregroundColor(textColor)
                        }
                    }
                }
            } else {
                Text("Loading...")
                    .foregroundColor(textColor)
            }
        }
        .background(backgroundColor)
        .padding()
    }

    // Computed properties for background and text colors
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.96)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
}

// Assuming you have the challengeManager and colorSchemes to preview the view
struct AllocatorView_Previews: PreviewProvider {
    static var previews: some View {
        AllocatorView(colorSchemes: [:])
            .environmentObject(ChallengeManager())
    }
}

// Assuming a mock PlayData JSON file in the main bundle

// The app's main entry point
@main
struct ChallengeGameApp: App {
  private var challengeManager = ChallengeManager()
  @State var tapped :IdentifiablePoint? = nil
  
  var body: some Scene {
    WindowGroup {
      TestView(size: starting_size, topics: starting_topics){ row, col in
        print("tapped \(row) \(col)")
        tapped=IdentifiablePoint(row: row,col: col)
      }
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
          let row = tapped.row; let col = tapped.col
          let index = row*starting_size+col+1 // 1 origined
          Text ("tapped \( row) \( col) index: \(index)")
           
          if  let ch = challengeManager.getChallenge(at:(index)) {
            Text(ch.question)
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
