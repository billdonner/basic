//
//  ChaMan.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import Foundation

enum ChallengeError: Error {
  case notfound
}


// The manager class to handle Challenge-related operations and state
@Observable
class ChaMan {
    internal init(playData: PlayData) {
        self.playData = playData
        self.stati = []
        self.tinfo = [:]
    }
    
    // TopicInfo is built from PlayData and is used to improve performance by simplifying searching and
    // eliminating lots of scanning to get counts
    struct TopicInfo {
        let topicname: String
        var totalcount: Int
        var freecount: Int
        var replacedcount: Int
        var rightcount: Int
        var wrongcount: Int
        var ch: [Int] // indexes into stati
    }
    
    // tinfo and stati must be maintained in sync
    // tinfo["topicname"].ch[123] and stati[123] are in sync with everychallenge[123]
    
    private(set) var tinfo: [String: TopicInfo]  // Dictionary indexed by topic
    private(set) var stati: [ChallengeStatus]  // Using array instead of dictionary
    
    private(set) var playData: PlayData {
        didSet {
            // Invalidate the cache when playData changes
            invalidateAllTopicsCache()
            invalidateAllChallengesCache()
        }
    }
    
    // Cache for allChallenges
    private var _allChallenges: [Challenge]?
    var everyChallenge: [Challenge] {
        // If _allChallenges is nil, compute the value and cache it
        if _allChallenges == nil {
            _allChallenges = playData.gameDatum.flatMap { $0.challenges }
        }
        // Return the cached value
        return _allChallenges!
    }
    
    // Cache for allTopics
    private var _allTopics: [String]?
    var everyTopicName: [String] {
        // If _allTopics is nil, compute the value and cache it
        if _allTopics == nil {
            _allTopics = playData.topicData.topics.map { $0.name }
        }
        // Return the cached value
        return _allTopics!
    }
    
    // Method to invalidate the allChallenges cache
    func invalidateAllChallengesCache() {
        _allChallenges = nil
    }
    
    // Method to invalidate the cache
    func invalidateAllTopicsCache() {
        _allTopics = nil
    }
    
  // Allocate N challenges nearly evenly from specified topics, taking from any topic if needed
     func allocateChallenges(forTopics topics: [String], count n: Int) -> AllocationResult {
         var allocatedChallenges: [Challenge] = []
         var topicIndexes: [String: [Int]] = [:]
         
         // Defensive check for empty topics array
         guard !topics.isEmpty else {
             return .error(.emptyTopics)
         }
         
         // Populate the dictionary with indexes for each topic
         for topic in topics {
             if let topicInfo = tinfo[topic] {
                 topicIndexes[topic] = topicInfo.ch
             } else {
                 return .error(.invalidTopics([topic]))
             }
         }
         
         // Calculate the number of challenges to allocate from each topic
         let challengesPerTopic = n / topics.count
         var remainingChallenges = n % topics.count
         
         // Allocate challenges nearly evenly from specified topics
         for topic in topics {
             if let indexes = topicIndexes[topic], !indexes.isEmpty {
                 let countToAllocate = challengesPerTopic + (remainingChallenges > 0 ? 1 : 0)
                 let allocatedIndexes = indexes.prefix(countToAllocate)
                 allocatedChallenges.append(contentsOf: allocatedIndexes.map { everyChallenge[$0] })
                 remainingChallenges -= 1
                 
                 // Update topicIndexes
                 topicIndexes[topic] = Array(indexes.dropFirst(countToAllocate))
                 
                 // Update tinfo to keep it in sync
                 if var topicInfo = tinfo[topic] {
                     topicInfo.ch = topicIndexes[topic]!
                     topicInfo.freecount -= allocatedIndexes.count
                     tinfo[topic] = topicInfo
                 }
             }
         }
         
         // If not enough challenges, take from any available topic
         while allocatedChallenges.count < n {
             var added = false
             for (topic, indexes) in topicIndexes {
                 if !indexes.isEmpty {
                     allocatedChallenges.append(everyChallenge[indexes.first!])
                     
                     // Update topicIndexes
                     topicIndexes[topic] = Array(indexes.dropFirst(1))
                     
                     // Update tinfo to keep it in sync
                     if var topicInfo = tinfo[topic] {
                         topicInfo.ch = topicIndexes[topic]!
                         topicInfo.freecount -= 1
                         tinfo[topic] = topicInfo
                     }
                     
                     if allocatedChallenges.count == n {
                         break
                     }
                     
                     added = true
                 }
             }
             
             // If no more challenges can be allocated, break to avoid an infinite loop
             if !added {
                 return .error(.insufficientChallenges)
             }
         }
         
         return .success(allocatedChallenges)
     }
     
     // Deallocate challenges at specified indexes and update internal structures
     func deallocAt(_ indexes: [Int]) -> AllocationResult {
         var topicIndexes: [String: [Int]] = [:]
         var invalidIndexes: [Int] = []

         // Collect the indexes of the challenges to deallocate and group by topic
         for index in indexes {
             if index >= everyChallenge.count {
                 invalidIndexes.append(index)
                 continue
             }

             let challenge = everyChallenge[index]
             let topic = challenge.topic // Assuming `Challenge` has a `topic` property

             if topicIndexes[topic] == nil {
                 topicIndexes[topic] = []
             }
             topicIndexes[topic]?.append(index)
         }

         // Check for invalid indexes
         if !invalidIndexes.isEmpty {
             return .error(.invalidTopics(["Invalid indexes: \(invalidIndexes)"]))
         }

         // Update tinfo to deallocate challenges
         for (topic, indexes) in topicIndexes {
             if var topicInfo = tinfo[topic] {
                 // Remove indexes from topicInfo.ch
                 topicInfo.ch.removeAll { indexes.contains($0) }
                 topicInfo.freecount += indexes.count

                 // Update tinfo to keep it in sync
                 tinfo[topic] = topicInfo
             } else {
                 return .error(.invalidTopics([topic]))
             }
         }

         // Update stati to reflect deallocation
         for index in indexes {
             if index < stati.count {
                 stati[index] = .inReserve // Set the status to inReserve
             }
         }

         return .success([])
     }
     
     // Put back challenges into the general pool for re-allocation
     func putback(indexes: [Int]) -> AllocationResult {
         var topicIndexes: [String: [Int]] = [:]
         var invalidIndexes: [Int] = []
         
         // Collect the indexes of the challenges to put back and group by topic
         for index in indexes {
             if index >= everyChallenge.count {
                 invalidIndexes.append(index)
                 continue
             }
             
             let challenge = everyChallenge[index]
             let topic = challenge.topic // Assuming `Challenge` has a `topic` property
             
             if topicIndexes[topic] == nil {
                 topicIndexes[topic] = []
             }
             topicIndexes[topic]?.append(index)
         }
         
         // Check for invalid indexes
         if !invalidIndexes.isEmpty {
             return .error(.invalidTopics(["Invalid indexes: \(invalidIndexes)"]))
         }
         
         // Update tinfo to put back challenges
         for (topic, indexes) in topicIndexes {
             if var topicInfo = tinfo[topic] {
                 // Add indexes back to topicInfo.ch 
               topicInfo.ch.append(contentsOf: indexes)
               topicInfo.ch.sort() // Ensure the list remains sorted
               topicInfo.freecount += indexes.count
               
               // Update tinfo to keep it in sync
               tinfo[topic] = topicInfo
           } else {
               return .error(.invalidTopics([topic]))
           }
       }
       
       // Update stati to reflect deallocation
       for index in indexes {
           if index < stati.count {
               stati[index] = .inReserve // Set the status to inReserve
           }
       }
       
       return .success([])
   }

   // Get the count of allocated challenges for a specific topic name
   func allocatedChallengesCount(for topicName: String) -> Int {
       guard let topicInfo = tinfo[topicName] else {
           print("Warning: Topic \(topicName) not found in tinfo.")
           return 0
       }
       
       return topicInfo.totalcount - topicInfo.freecount
   }
}

// Result enum to handle allocation and deallocation outcomes
enum AllocationResult {
   case success([Challenge])
   case error(AllocationError)
   
   enum AllocationError: Error {
       case emptyTopics
       case invalidTopics([String])
       case insufficientChallenges
   }
}


          
extension ChaMan {
  
  
  func loadAllData  (gameBoard:GameBoard) {
    do {
      if  let gb =  GameBoard.loadGameBoard() {
        gameBoard.cellstate = gb.cellstate
        gameBoard.size = gb.size
        gameBoard.board = gb.board
        gameBoard.gimmees = gb.gimmees
        gameBoard.playcount = gb.playcount
        gameBoard.rightcount = gb.rightcount
        gameBoard.wrongcount = gb.wrongcount
        gameBoard.lostcount = gb.lostcount
        gameBoard.woncount = gb.woncount
        gameBoard.replacedcount = gb.replacedcount
        gameBoard.totaltime = gb.totaltime
        gameBoard.gamestate = gb.gamestate
        gameBoard.topicsinplay = gb.topicsinplay
      }
      try self.loadPlayData(from: playDataFileName)
      
    } catch {
      print("Failed to load PlayData: \(error)")
    }
  }
  func loadPlayData(from filename: String ) throws {
    let starttime = Date.now
    
    guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
      throw URLError(.fileDoesNotExist)
    }
    
    let data = try Data(contentsOf: url)
    let pd = try JSONDecoder().decode(PlayData.self, from: data)
    self.playData = pd
    if let loadedStatuses = loadChallengeStatuses() {
      self.stati = loadedStatuses
    } else {
      let challenges = pd.gameDatum.flatMap { $0.challenges}
      var cs:[ChallengeStatus] = []
      for _ in 0..<challenges.count {
        cs.append(.inReserve)
      }
      self.stati = cs
    }
    for t in playData.topicData.topics  {
      let ti = TopicInfo(topicname: t.name, totalcount: 0, freecount: 0, replacedcount: 0, rightcount: 0, wrongcount: 0, ch: [])
      tinfo[t.name] = ti
    }
    
    print("Loaded PlayData in \(formatTimeInterval(Date.now.timeIntervalSince(starttime))) secs")
  }
  
  //  func saveChallengeStatus( ) {
  //    saveChallengeStatuses(stati)
  //  }
  
  func dumpTopics () {
    print("Dump of Challenge Allocations")
    print("=============================")
    print("Allocated: \( allocatedChallengesCount()) Free: \( freeChallengesCount())")
    for topic in playData.topicData.topics {
      print("\(topic.name) \(allocatedChallengesCount(for:topic.name)) \(freeChallengesCount(for:topic.name))")
    }
    print("=============================")
  }
  

  func setStatus(for challenge:Challenge, index:Int,  status: ChallengeStatus)  {
    defer {
      saveChallengeStatuses(stati)
    }
    stati[index] = status
    return
  }
  func resetChallengeStatuses(at challengeIndices: [Int]) {
    defer {
      saveChallengeStatuses(stati)
    }
    for index in challengeIndices {
      stati[index]  = ChallengeStatus.inReserve
    }
  }
  
  func totalresetofAllChallengeStatuses(gameBoard:GameBoard) {
    defer {
      saveChallengeStatuses(stati)
    }
    //if let playData = playData {
    self.stati = [ChallengeStatus](repeating:ChallengeStatus.inReserve, count: playData.gameDatum.flatMap { $0.challenges }.count)
  }
 
  // Allocates N challenges nearly evenly from specified topics, taking from any topic in the list if needed
  func xallocateChallenges(forTopics topics: [String], count n: Int) -> [Challenge]? {
    var topicChallengeMap: [String: [Int]] = [:]
    var allocatedChallenges: [Challenge] = []
    var allocatedCount = 0
    
    defer {
      saveChallengeStatuses(stati)
    }
    
    // Initialize the topicChallengeMap
    for (index, challenge) in everyChallenge.enumerated() {
      if topics.contains(challenge.topic) && stati[index]  == .inReserve {
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
        if stati[index]  == .inReserve { // Double-check that the challenge is still in reserve
          stati[index]  = ChallengeStatus.allocated
          allocatedChallenges.append(everyChallenge[index])
          allocatedCount += 1
        }
      }
    }
    
    // Allocate any remaining challenges, taking from any available topics
    if allocatedCount < n {
      let additionalChallengesNeeded = n - allocatedCount
      let remainingAvailableChallenges = topics.flatMap { topicChallengeMap[$0] ?? [] }
      for index in remainingAvailableChallenges.prefix(additionalChallengesNeeded) {
        if stati[index] == ChallengeStatus.inReserve { // Double-check that the challenge is still in reserve
          stati[index]  = ChallengeStatus.allocated
          allocatedChallenges.append(everyChallenge[index])
          allocatedCount += 1
        }
      }
    }
    
    return allocatedCount == n ? allocatedChallenges.shuffled() : nil
  }
  
  // get challenge at index
  func getChallenge(row: Int,col:Int) -> Challenge? {
    let index = row*starting_size+col
    let chs = everyChallenge
    guard index >= 0 && index < chs.count else { return nil }
    return chs[index]
  }
  
  // Replaces one challenge with another, marking the old one as abandoned
  func replaceChallenge(at index: Int) -> Challenge? {
    guard index >= 0 && index < everyChallenge.count else { return nil }
    defer {
      saveChallengeStatuses(stati)
    }
    // Mark the old challenge as abandoned
    stati[index]  = .abandoned
    // Allocate a new challenge from the same topic
    let topic = everyChallenge[index].topic
    let topicChallenges = everyChallenge.enumerated().filter { $0.element.topic == topic && stati[$0.offset]  == .inReserve }
    
    guard let newChallengeIndex = topicChallenges.first?.offset else {
      return nil
    }
    
    stati[newChallengeIndex] = .allocated
    return everyChallenge[newChallengeIndex]
  }
  
  
  // Helper functions to get counts
  
  
  func allocatedChallengesCount() -> Int {
    return  stati.filter { $0 == .allocated }.count
  }
  
  func freeChallengesCount() -> Int {
    return  stati.filter { $0   == .inReserve }.count
  }
  

  
  func abandonedChallengesCount(for topicName: String) -> Int {
    guard let topicInfo = tinfo[topicName] else {
        return -1
    }
    return topicInfo.replacedcount
  }
  func correctChallengesCount(for topicName: String) -> Int {
    guard let topicInfo = tinfo[topicName] else {
        return -1
    }
    return topicInfo.rightcount
  }
  func incorrectChallengesCount(for topicName: String )-> Int {
    guard let topicInfo = tinfo[topicName] else {
        return -1
    }
    return topicInfo.wrongcount
  }
  
  func freeChallengesCount(for topicName: String) -> Int {
    guard let topicInfo = tinfo[topicName] else {
        return -1
    }
    return topicInfo.freecount
  }
  
}



// Allocates N challenges from all challenges
//  func allocateChallenges(_ n: Int) -> [Challenge]? {
//    defer {
//      saveChallengeStatuses(stati)
//    }
//    var allocatedChallenges: [Challenge] = []
//    var allocatedCount = 0
//    for index in 0..<everyChallenge.count {
//      if stati[index].val == .inReserve {
//        stati[index].val = .allocated
//        allocatedChallenges.append(everyChallenge[index])
//        allocatedCount += 1
//        if allocatedCount == n { break }
//      }
//    }
//    return allocatedCount == n ? allocatedChallenges : nil
//  }

//  // Allocates N challenges where the topic is specified
//  func allocateChallenges(for topic: String, count n: Int) -> [Challenge]? {
//    defer {
//      saveChallengeStatuses(stati)
//    }
//
//    var allocatedChallenges: [Challenge] = []
//    var allocatedCount = 0
//    for index in 0..<everyChallenge.count {
//      if everyChallenge[index].topic == topic && stati[index].val == .inReserve {
//        stati[index].val = .allocated
//        allocatedChallenges.append(everyChallenge[index])
//        allocatedCount += 1
//        if allocatedCount == n { break }
//      }
//    }
//    return allocatedCount == n ? allocatedChallenges : nil
//  }
