 
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

enum ChallengeStatus: Codable {
   case inReserve
   case allocated
   case playedCorrectly
   case playedIncorrectly
   case abandoned
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
            ContentView()
                .environmentObject(challengeManager)
                .onAppear {
                    do {
                        try challengeManager.playData = loadPlayData(from: jsonFileName)
                    } catch {
                        print("Failed to load PlayData: \(error)")
                    }
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
// The manager class to handle Challenge-related operations and state
@Observable
class ChallengeManager : ObservableObject{
  internal init(playData: PlayData? = nil, challengeStatuses: [String : ChallengeStatus] = [:]) {
    self.playData = playData
    self.challengeStatuses = challengeStatuses
  }
  
   var playData: PlayData?
  var challengeStatuses: [String: ChallengeStatus]  // id -> status
    

    
    // Extracts all challenges from PlayData
    func getAllChallenges() -> [Challenge] {
        guard let playData = playData else { return [] }
        return playData.gameDatum.flatMap { $0.challenges }
    }
    
    // Allocates N challenges from all challenges
    func allocateChallenges(_ n: Int) -> Bool {
        let allChallenges = getAllChallenges()
        let availableChallenges = allChallenges.filter { challengeStatuses[$0.id] == nil }
        guard availableChallenges.count >= n else {
            return false
        }
        availableChallenges.prefix(n).forEach { challenge in
            challengeStatuses[challenge.id] = .allocated
        }
        return true
    }
    
    // Allocates N challenges where the topic is specified
    func allocateChallenges(for topic: String, count n: Int) -> Bool {
        let topicChallenges = getAllChallenges().filter { $0.topic == topic }
        let availableTopicChallenges = topicChallenges.filter { challengeStatuses[$0.id] == nil }
        
        var allocatedCount = 0
        
        availableTopicChallenges.prefix(n).forEach { challenge in
            challengeStatuses[challenge.id] = .allocated
            allocatedCount += 1
        }
        
        if allocatedCount < n {
            let remainingCount = n - allocatedCount
            return allocateChallenges(remainingCount)
        }
        
        return true
    }
  
  // Allocates N challenges nearly evenly from specified topics, taking from any topic in the list if needed
  func allocateChallenges(forTopics topics: [String], count n: Int) -> Bool {
      var topicChallengeMap: [String: [Challenge]] = [:]
      var allocatedCount = 0
      var challengesPerTopic: [String: Int] = [:]
      
      // Initialize the topicChallengeMap and challengesPerTopic dictionary
      topics.forEach { topic in
          let topicChallenges = getAllChallenges().filter { $0.topic == topic && challengeStatuses[$0.id] == nil }
          topicChallengeMap[topic] = topicChallenges
          challengesPerTopic[topic] = topicChallenges.count
      }
      
      // Calculate how many challenges to allocate per topic initially
      let challengesPerTopicInitial = n / topics.count
      let remainingChallenges = n % topics.count
      
      // Allocate challenges from each topic nearly evenly
      for topic in topics {
          let availableChallenges = topicChallengeMap[topic] ?? []
          
          let challengesToAllocate = min(challengesPerTopicInitial, availableChallenges.count)
          for challenge in availableChallenges.prefix(challengesToAllocate) {
              challengeStatuses[challenge.id] = .allocated
              allocatedCount += 1
          }
      }
      
      // Allocate any remaining challenges, taking from any available topics
      if allocatedCount < n {
          let additionalChallengesNeeded = n - allocatedCount
          
          // Flatten all remaining available challenges from all specified topics
          let remainingAvailableChallenges = topics.flatMap { topicChallengeMap[$0] ?? [] }.filter { challengeStatuses[$0.id] == nil }
          
          guard remainingAvailableChallenges.count >= additionalChallengesNeeded else {
              return false
          }
          
          // Allocate the remaining needed challenges
          for challenge in remainingAvailableChallenges.prefix(additionalChallengesNeeded) {
              challengeStatuses[challenge.id] = .allocated
              allocatedCount += 1
          }
      }
      
      return allocatedCount == n
  }
    // Replaces one challenge with another, marking the old one as abandoned
    func replaceChallenge(challengeID: String) -> Bool {
      guard  let oldChallenge = getAllChallenges().first(where: { $0.id == challengeID }) else {
            return false
        }
        
        // Mark the old challenge as abandoned
        challengeStatuses[oldChallenge.id] = .abandoned
        
        // Allocate a new challenge from the same topic
        let topicChallenges = getAllChallenges().filter { $0.topic == oldChallenge.topic }
        let availableChallenges = topicChallenges.filter { challengeStatuses[$0.id] == nil }
        
        guard let newChallenge = availableChallenges.first else {
            return false
        }
        
        challengeStatuses[newChallenge.id] = .allocated
        return true
    }
  
 
  // Replaces the last topic allocated
  func replaceLastAllocatedTopic() -> Bool {
      // Get the ID of the last allocated challenge
      guard let lastAllocatedChallengeID = challengeStatuses.filter({ $0.value == .allocated }).keys.sorted().last else {
          return false
      }
      
      // Replace the last allocated challenge
      return replaceChallenge(challengeID: lastAllocatedChallengeID)
  }
 
}

// The main content view
struct ContentView: View {
  @EnvironmentObject var challengeManager: ChallengeManager
  @State var  succ = false
    var body: some View {
        VStack {
            if let playData = challengeManager.playData {
              Button (action: {
                succ =  challengeManager.allocateChallenges(forTopics  : ["Actors","Animals"] , count:16)
              }) {
                Text("a 16").opacity(succ ? 1.0:0.5)
              }
              Button (action: {
                succ =  challengeManager.allocateChallenges(forTopics  : ["Actors","Animals"] , count:36)
              }) {
                Text("a 36").opacity(succ ? 1.0:0.5)
              }
              //IT IS EXTREMELY IMPORTANT TO NOT USE FORM OR LIST HERE
              ScrollView {
                ForEach(playData.topicData.topics, id: \.name) { topic in
                  VStack {
                    HStack {
                      Text(topic.name)
                      Spacer()
                      Text("A: \(allocatedChallengesCount(for: topic))")
                      Text("F: \(freeChallengesCount(for: topic))")
                      Text("G: \(abandonedChallengesCount(for: topic))")
                    }
                    HStack{
                      Button (action: {
                        succ =  challengeManager.allocateChallenges(for  : topic.name, count:1)
                      }) {
                        Text("a 1").opacity(succ ? 1.0:0.5)
                      }
                      
                      Button (action: {
                        succ =  challengeManager.allocateChallenges(for  : topic.name, count:10)
                      }) {
                        Text("a 10").opacity(succ ? 1.0:0.5)
                      }
                      
                      Button (action: {
                        succ =
                        challengeManager.replaceLastAllocatedTopic()
                      }) {
                        Text("r 1").opacity(succ ? 1.0:0.5)
                      }
                    }
                  }
                  .safeAreaPadding()
                }
              }
              //IMPORTANT
            } else {
                Text("Loading...")
            }
              
        }
    }
    
    // Helper functions to get counts
    func allocatedChallengesCount(for topic: Topic) -> Int {
        return countChallenges(for: topic, with: .allocated)
    }
    
    func freeChallengesCount(for topic: Topic) -> Int {
        return challengeManager.getAllChallenges().filter { $0.topic == topic.name && challengeManager.challengeStatuses[$0.id] == nil }.count
    }
    
    func abandonedChallengesCount(for topic: Topic) -> Int {
        return countChallenges(for: topic, with: .abandoned)
    }
    
    func countChallenges(for topic: Topic, with status: ChallengeStatus) -> Int {
        return challengeManager.getAllChallenges().filter { $0.topic == topic.name && challengeManager.challengeStatuses[$0.id] == status }.count
    }
}

//#Preview {
// 
// ContentView() .environment(
//  ChallengeManager(playData: try! loadPlayData(from: jsonFileName)))
//  
//}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView() .environment(
      ChallengeManager(playData: try! loadPlayData(from: jsonFileName)))
  }
}
