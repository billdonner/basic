
import SwiftUI

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

enum AllocationStatus: Codable {
    case success
    case partial
    case failure
}

// Assuming a mock PlayData JSON file in the main bundle
let jsonFileName = "playdata.json"

// The app's main entry point
@main
struct ChallengeGameApp: App {
    private var challengeManager = ChallengeManager()

    var body: some Scene {
        WindowGroup {
            TestAllocatorView()
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
        }
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
    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
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
    
    // Extracts all challenges from PlayData
    func getAllChallenges() -> [Challenge] {
        guard let playData = playData else { return [] }
        return playData.gameDatum.flatMap { $0.challenges }
    }
    
    // Allocates N challenges from all challenges
    func allocateChallenges(_ n: Int) -> Bool {
        let allChallenges = getAllChallenges()
        var allocatedCount = 0
        for index in 0..<allChallenges.count {
            if challengeStatuses[index] == .inReserve {
                challengeStatuses[index] = .allocated
                allocatedCount += 1
                if allocatedCount == n { break }
            }
        }
        return allocatedCount == n
    }
    
    // Allocates N challenges where the topic is specified
    func allocateChallenges(for topic: String, count n: Int) -> Bool {
      defer {
        saveChallengeStatuses(challengeStatuses)
      }
        let allChallenges = getAllChallenges()
        var allocatedCount = 0
        for index in 0..<allChallenges.count {
            if allChallenges[index].topic == topic && challengeStatuses[index] == .inReserve {
                challengeStatuses[index] = .allocated
                allocatedCount += 1
                if allocatedCount == n { break }
            }
        }
        return allocatedCount == n
    }
    
    // Allocates N challenges nearly evenly from specified topics, taking from any topic in the list if needed
    func allocateChallenges(forTopics topics: [String], count n: Int) -> Bool {
        let allChallenges = getAllChallenges()
        var topicChallengeMap: [String: [Int]] = [:]
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
            return false
        }
        
        // Allocate challenges from each topic nearly evenly
        for topic in topics {
            let availableChallenges = topicChallengeMap[topic] ?? []
            let challengesToAllocate = min(challengesPerTopicInitial, availableChallenges.count)
            for index in availableChallenges.prefix(challengesToAllocate) {
                challengeStatuses[index] = .allocated
                allocatedCount += 1
            }
        }
        
        // Allocate any remaining challenges, taking from any available topics
        if allocatedCount < n {
            let additionalChallengesNeeded = n - allocatedCount
            let remainingAvailableChallenges = topics.flatMap { topicChallengeMap[$0] ?? [] }
            for index in remainingAvailableChallenges.prefix(additionalChallengesNeeded) {
                challengeStatuses[index] = .allocated
                allocatedCount += 1
            }
        }
        
        return allocatedCount == n
    }
    
    // Replaces one challenge with another, marking the old one as abandoned
    func replaceChallenge(at index: Int) -> Bool {
        guard index >= 0 && index < getAllChallenges().count else { return false }
      defer {
        saveChallengeStatuses(challengeStatuses)
      }
        // Mark the old challenge as abandoned
        challengeStatuses[index] = .abandoned

        // Allocate a new challenge from the same topic
        let topic = getAllChallenges()[index].topic
        let topicChallenges = getAllChallenges().enumerated().filter { $0.element.topic == topic && challengeStatuses[$0.offset] == .inReserve }
        
        guard let newChallengeIndex = topicChallenges.first?.offset else {
            return false
        }
        
        challengeStatuses[newChallengeIndex] = .allocated
        return true
    }

    // Replaces the last topic allocated
    func replaceLastAllocatedTopic() -> Bool {
        // Get the index of the last allocated challenge
        guard let lastAllocatedIndex = challengeStatuses.lastIndex(of: .allocated) else {
            return false
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

// The main content view
struct TestAllocatorView: View {
    @EnvironmentObject var challengeManager: ChallengeManager
    @State var succ = false
    var body: some View {
        VStack {
            Text("Current - \(jsonFileName)").font(.headline).opacity(succ ? 1.0:0.5)
            AllocatorView().background(Color.indigo).foregroundColor(.white)
            if let playData = challengeManager.playData {
                Button (action: {
                    succ = challengeManager.allocateChallenges(forTopics : ["Actors","Animals"] , count:16)
                }) {
                    Text("allocate 4x4")
                }
                Button (action: {
                    succ = challengeManager.allocateChallenges(forTopics : ["Actors","Animals"] , count:36)
                }) {
                    Text("allocate 6x6")
                }
                Text("Hacking").font(.headline).opacity(succ ? 1.0:0.5)
                //IT IS EXTREMELY IMPORTANT TO NOT USE FORM OR LIST HERE
                ScrollView {
                    ForEach(playData.topicData.topics, id: \.name) { topic in
                        VStack {
                            HStack {
                                Text(topic.name)
                                Spacer()
                                Text("A: \(challengeManager.allocatedChallengesCount(for: topic))")
                                Text("F: \(challengeManager.freeChallengesCount(for: topic))")
                                Text("G: \(challengeManager.abandonedChallengesCount(for: topic))")
                            }
                            HStack{
                                Button (action: {
                                    succ = challengeManager.allocateChallenges(for : topic.name, count:1)
                                }) {
                                    Text("a 1").opacity(succ ? 1.0:0.5)
                                }
                                
                                Button (action: {
                                    succ = challengeManager.allocateChallenges(for : topic.name, count:10)
                                }) {
                                    Text("a 10").opacity(succ ? 1.0:0.5)
                                }
                                
                                Button (action: {
                                    succ = challengeManager.replaceLastAllocatedTopic()
                                }) {
                                    Text("r 1").opacity(succ ? 1.0:0.5)
                                }
                            }
                        }
                        .safeAreaPadding()
                    }
                }.background(Color.yellow)
                //IMPORTANT
            } else {
                Text("Loading...")
            }
        }
    }
}
    
struct AllocatorView: View {
    @EnvironmentObject var challengeManager: ChallengeManager
    @State var succ = false
    var body: some View {
        VStack {
            if let playData = challengeManager.playData {

                //IT IS EXTREMELY IMPORTANT TO NOT USE FORM OR LIST HERE
                ScrollView {
                    ForEach(playData.topicData.topics, id: \.name) { topic in
                        VStack(spacing:0) {
                            HStack {
                                Text(topic.name)
                                Spacer()
                                Text("A: \(challengeManager.allocatedChallengesCount(for: topic))")
                                Text("F: \(challengeManager.freeChallengesCount(for: topic))")
                                Text("G: \(challengeManager.abandonedChallengesCount(for: topic))")
                            }
                        }.padding(.horizontal)
                    }
                }
                //IMPORTANT
            } else {
                Text("Loading...")
            }
        }
    }
}
    
struct TestAllocatorView_Previews: PreviewProvider {
    static var previews: some View {
        TestAllocatorView() .environment(
            ChallengeManager(playData: try! loadPlayData(from: jsonFileName)))
    }
}
 
