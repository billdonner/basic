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
struct TopicInfo : Codable {
      let topicname: String
      var alloccount: Int
      var freecount: Int
      var replacedcount: Int
      var rightcount: Int
      var wrongcount: Int
      var ch: [Int] // indexes into stati
  }

extension TopicInfo {
  // Get the file path for storing challenge statuses
  static func getTopicInfoFilePath() -> URL {
      let fileManager = FileManager.default
      let urls = fileManager.urls(for:.documentDirectory, in: .userDomainMask)
      return urls[0].appendingPathComponent("topicinfo.json")
  }
  // Save the topicInfo to a file
  static func saveTopicInfo (_ info:[String:TopicInfo]) {
    let filePath = Self.getTopicInfoFilePath()
      do {
          let data = try JSONEncoder().encode(info)
          try data.write(to: filePath)
      } catch {
          print("Failed to save TopicInfo: \(error)")
      }
  }

  // Load the challenge statuses from a file
  static func loadTopicInfo() -> [String:TopicInfo]? {
      let filePath = getTopicInfoFilePath()
      do {
          let data = try Data(contentsOf: filePath)
          let dict = try JSONDecoder().decode([String:TopicInfo].self, from: data)
          return dict
      } catch {
          print("Failed to load TopicInfo: \(error)")
          return nil
      }
  }

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

  enum ChallengeStatus : Int, Codable  {
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


    // tinfo and stati must be maintained in sync
    // tinfo["topicname"].ch[123] and stati[123] are in sync with everychallenge[123]
    
    var tinfo: [String: TopicInfo]  // Dictionary indexed by topic
    var stati: [ChallengeStatus]  // Using array instead of dictionary
    
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
      get {
          // If _allChallenges is nil, compute the value and cache it
          if _allChallenges == nil {
              _allChallenges = playData.gameDatum.flatMap { $0.challenges }
          }
          // Return the cached value
          return _allChallenges!
      }
      set {
          // Update the cache with the new value
          _allChallenges = newValue
      }
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
  func bumpWrongcount(topic:String){
    if var t =  tinfo[topic] {
      t.wrongcount += 1
     tinfo[topic] = t
    }
  }
  func bumpRightcount(topic:String){
    if var t =  tinfo[topic] {
      t.rightcount += 1
     tinfo[topic] = t
    }
  }
    // Allocate N challenges nearly evenly from specified topics, taking from any topic if needed
    func allocateChallenges(forTopics topics: [String], count n: Int) -> AllocationResult {
        var allocatedChallengeIndices: [Int] = []
        var topicIndexes: [String: [Int]] = [:]
        
        // Defensive check for empty topics array
        guard !topics.isEmpty else {
            return .error(.emptyTopics)
        }
        
        // Populate the dictionary with indexes for each specified topic
        for topic in topics {
            if let topicInfo = tinfo[topic] {
                topicIndexes[topic] = topicInfo.ch
            } else {
                return .error(.invalidTopics([topic]))
            }
        }
        
        // Calculate the total number of available challenges in the specified topics
        let totalFreeChallenges = topics.reduce(0) { $0 + (tinfo[$1]?.freecount ?? 0) }
        
        // Check if total available challenges are less than required
        if totalFreeChallenges < n {
            return .error(.insufficientChallenges)
        }
        
        // First pass: Allocate challenges nearly evenly from the specified topics
        let challengesPerTopic = n / topics.count
        var remainingChallenges = n % topics.count
        
        for topic in topics {
            if let nindexes = topicIndexes[topic], !nindexes.isEmpty {
              let indexes = nindexes.shuffled()
                let countToAllocate = min(indexes.count, challengesPerTopic + (remainingChallenges > 0 ? 1 : 0))
                let allocatedIndexes = indexes.prefix(countToAllocate)
                allocatedChallengeIndices.append(contentsOf: allocatedIndexes)
                remainingChallenges -= 1
                
                // Update topicIndexes
                topicIndexes[topic] = Array(indexes.dropFirst(countToAllocate))
                
                // Update tinfo to keep it in sync
                if var topicInfo = tinfo[topic] {
                    topicInfo.ch = topicIndexes[topic] ?? []
                    topicInfo.freecount -= allocatedIndexes.count
                topicInfo.alloccount += allocatedIndexes.count
                    tinfo[topic] = topicInfo
                }
            }
        }
        
        // Second pass: Allocate remaining challenges from the specified topics even if imbalanced
        for topic in topics {
            if allocatedChallengeIndices.count >= n {
                break
            }
            
            if let nindexes = topicIndexes[topic], !nindexes.isEmpty {
              let indexes = nindexes.shuffled()
                let remainingToAllocate = n - allocatedChallengeIndices.count
                let countToAllocate = min(indexes.count, remainingToAllocate)
                let allocatedIndexes = indexes.prefix(countToAllocate)
                allocatedChallengeIndices.append(contentsOf: allocatedIndexes)
                
                // Update topicIndexes
                topicIndexes[topic] = Array(indexes.dropFirst(countToAllocate))
                
                // Update tinfo to keep it in sync
                if var topicInfo = tinfo[topic] {
                    topicInfo.ch = topicIndexes[topic] ?? []
                    topicInfo.freecount -= allocatedIndexes.count
                  topicInfo.alloccount += allocatedIndexes.count
                    tinfo[topic] = topicInfo
                }
            }
        }
        
        // Third pass: If still not enough challenges, take from any available topic
        if allocatedChallengeIndices.count < n {
            for (topic, info) in tinfo {
                if !topics.contains(topic) { // Skip specified topics since they have already been considered
                   let nindexes = info.ch
                    if !nindexes.isEmpty {
                      let indexes = nindexes.shuffled()
                        let remainingToAllocate = n - allocatedChallengeIndices.count
                        let countToAllocate = min(indexes.count, remainingToAllocate)
                        let allocatedIndexes = indexes.prefix(countToAllocate)
                        allocatedChallengeIndices.append(contentsOf: allocatedIndexes)
                        
                        // Update topicIndexes
                        var updatedIndexes = indexes
                        updatedIndexes.removeFirst(countToAllocate)
                        topicIndexes[topic] = updatedIndexes
                        
                        // Update tinfo to keep it in sync
                        if var topicInfo = tinfo[topic] {
                            topicInfo.ch = topicIndexes[topic] ?? []
                            topicInfo.freecount -= allocatedIndexes.count
                          
                        topicInfo.alloccount += allocatedIndexes.count
                            tinfo[topic] = topicInfo
                        }
                        
                        // Check if we have allocated enough challenges
                        if allocatedChallengeIndices.count >= n {
                            break
                        }
                    }
                }
            }
        }
        
        // Update stati to reflect allocation
        for index in allocatedChallengeIndices {
            stati[index] = .allocated
        }
      TopicInfo.saveTopicInfo(tinfo)
      return .success(allocatedChallengeIndices)//.shuffled()) // see if this works
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

            if stati[index] == .inReserve {
                invalidIndexes.append(index)
                continue
            }

            if topicIndexes[topic] == nil {
                topicIndexes[topic] = []
            }
            topicIndexes[topic]?.append(index)
        }

        // Check for invalid indexes
        if !invalidIndexes.isEmpty {
          return .error(.invalidDeallocIndices(invalidIndexes))
        }

        // Update tinfo to deallocate challenges
        for (topic, indexes) in topicIndexes {
            if var topicInfo = tinfo[topic] {
                // Remove indexes from topicInfo.ch
                for index in indexes {
                    if let pos = topicInfo.ch.firstIndex(of: index) {
                        topicInfo.ch.remove(at: pos)
                    }
                }
                topicInfo.freecount += indexes.count
              topicInfo.alloccount -= indexes.count 

                // Add the deallocated indexes back to topicInfo.ch
                topicInfo.ch.append(contentsOf: indexes)
                topicInfo.ch.sort()

                // Update tinfo to keep it in sync
                tinfo[topic] = topicInfo
//
//                print("Deallocated from topic \(topic): indexes \(indexes), freecount now \(topicInfo.freecount)")
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
      saveChallengeStatuses(stati)
      TopicInfo.saveTopicInfo(tinfo)
      return .success([])
  }

  // Replace a challenge at a specific index and update internal structures
  // Replace a challenge at a specific index and update internal structures
  func replaceChallenge(at index: Int) -> AllocationResult {
      guard index < everyChallenge.count else {
          return .error(.invalidTopics(["Invalid index: \(index)"]))
      }

      let challenge = everyChallenge[index]
      let topic = challenge.topic // Assuming `Challenge` has a `topic` property

      // Mark the old challenge as abandoned
    //****  stati[index] = .abandoned

      // Find a new challenge to replace the old one
      if var topicInfo = tinfo[topic] {
          if let newChallengeIndex = topicInfo.ch.first(where: { stati[$0] == .inReserve }) {
            let newChallenge = everyChallenge[newChallengeIndex]
            // swap the actual challenges
            everyChallenge[index] = newChallenge
            everyChallenge[newChallengeIndex] = challenge
            
            stati[newChallengeIndex] = .abandoned
            // dont need to change the indices because we swapped challenges
              ////topicInfo.ch.removeAll(where: { $0 == newChallengeIndex })
              topicInfo.replacedcount += 1
              topicInfo.freecount -= 1
              tinfo[topic] = topicInfo
              TopicInfo.saveTopicInfo(tinfo)
              // Return the index of the we supplied
              return .success([index])
          } else {
              return .error(.insufficientChallenges)
          }
      } else {
          return .error(.invalidTopics([topic]))
      }
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

  
  // Verify that tinfo and stati arrays are in sync
  func verifySync() -> Bool {
      for (topicName, topicInfo) in tinfo {
          var calculatedFreeCount = 0
          for index in topicInfo.ch {
              if index >= stati.count || index >= everyChallenge.count {
                  print("Index out of bounds in topic \(topicName)")
                  return false
              }
              if stati[index] == .inReserve {
                  calculatedFreeCount += 1
              }
          }
          if calculatedFreeCount != topicInfo.freecount {
              print("Free count mismatch in topic \(topicName): calculated \(calculatedFreeCount), expected \(topicInfo.freecount)")
              return false
          }
      }
      return true
  }
}


extension ChaMan {

  func loadAllData  (gs:GameState) {
    do {
      if  let gb =  GameState.loadGameState() {
        gs.cellstate = gb.cellstate
        gs.boardsize = gb.boardsize
        gs.board = gb.board
        gs.gimmees = gb.gimmees
        gs.playcount = gb.playcount
        gs.rightcount = gb.rightcount
        gs.wrongcount = gb.wrongcount
        gs.lostcount = gb.lostcount
        gs.woncount = gb.woncount
        gs.replacedcount = gb.replacedcount
        gs.totaltime = gb.totaltime
        gs.gamestate = gb.gamestate
        gs.topicsinplay = gb.topicsinplay
      }
      try self.loadPlayData(from: playDataFileName)
      
    } catch {
      print("Failed to load PlayData: \(error)")
    }
  }

  // Function to calculate freecount for each topic by examining PlayData
  func calculateFreeCount() -> [String: Int] {
    var freeCountByTopic: [String: Int] = [:]
    var allocatedCountByTopic: [String: Int] = [:]
    
    // Initialize counts for each topic
    for topic in playData.topicData.topics {
      freeCountByTopic[topic.name] = 0
      allocatedCountByTopic[topic.name] = 0
    }
    
    // Iterate through all challenges and count free ones
    for (index, challenge) in everyChallenge.enumerated() {
      if stati[index] == .inReserve {
        freeCountByTopic[challenge.topic, default: 0] += 1
      } else  if stati[index] == .allocated {
        allocatedCountByTopic[challenge.topic, default: 0] += 1
      }
    }
      return freeCountByTopic
  }
  
  func loadPlayData(from filename: String ) throws {
    let starttime = Date.now
    guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
      throw URLError(.fileDoesNotExist)
    }
    let data = try Data(contentsOf: url)
    let pd = try JSONDecoder().decode(PlayData.self, from: data)
    self.playData = pd
    if let loadedTinfo = TopicInfo.loadTopicInfo() {
      self.tinfo = loadedTinfo
    } else {
      self.tinfo = [:]
    }
        
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
    
    // calculate free counts by topic
    var freeCountByTopic: [String: Int] = [:]
    var allocCountByTopic: [String: Int] = [:]
    // Initialize counts for each topic
    for topic in playData.topicData.topics {
        freeCountByTopic[topic.name] = 0
     allocCountByTopic[topic.name] = 0
    }

    // Iterate through all challenges and count free ones
    for (index, challenge) in everyChallenge.enumerated() {
        if stati[index] == .inReserve {
            freeCountByTopic[challenge.topic, default: 0] += 1
        } else     if stati[index] == .allocated {
         allocCountByTopic[challenge.topic, default: 0] += 1
        }
    }
    
    //give them all the correct free count so we can alloate some
    let sortedChallengesByTopic = playData.gameDatum.flatMap { $0.challenges }.sorted { $0.topic < $1.topic }
    var lastTopic = ""
    var lastidx = -1
    var first = true
    var count = 0
    var accumulated:[Int] = []
    for (idx,challenge) in sortedChallengesByTopic.enumerated() {
      if challenge.topic == lastTopic {
        // same topic must bump count
        count += 1
        accumulated.append(idx)
      }
      else {
        if !first {
          // new topic, first push out one block
          let ti = TopicInfo(topicname: lastTopic, alloccount: allocCountByTopic[lastTopic] ?? 0, freecount: freeCountByTopic[lastTopic] ?? 0, replacedcount: 0, rightcount: 0, wrongcount: 0, ch: accumulated)
          tinfo[lastTopic] = ti
        }
        // then reset for next topic
        count = 0
        accumulated = []
      }
      lastTopic = challenge.topic
      lastidx = idx
      first = false
    }
    
    accumulated.append(lastidx)
    let ti = TopicInfo(topicname: lastTopic, alloccount: allocCountByTopic[lastTopic] ?? 0, freecount: freeCountByTopic[lastTopic] ?? 0, replacedcount: 0, rightcount: 0, wrongcount: 0, ch: accumulated)
    tinfo[lastTopic] = ti
    print("Loaded PlayData in \(formatTimeInterval(Date.now.timeIntervalSince(starttime))) secs")
  }
  func checkTopicConsistency(_ x:String) {
    var freecount = 0
    var alloccount = 0
    for t in  playData.topicData.topics {
      freecount += freeChallengesCount(for:t.name)
      alloccount += allocatedChallengesCount(for:t.name)
    }
  //  assert(freecount ==  freeChallengesCount(),x )
  //  assert(alloccount == allocatedChallengesCount(),x)
  }
  
  func dumpTopics () {
    print("Dump of Challenges By Topic")
    print("=============================")
    print("Allocated: \( allocatedChallengesCount()) Free: \( freeChallengesCount())")
    for topic in playData.topicData.topics {
      let pp = """
\(topic.name.paddedOrTruncated(toLength: 50, withPadCharacter: ".")) \(allocatedChallengesCount(for:topic.name)) \(freeChallengesCount(for:topic.name)) \(abandonedChallengesCount(for: topic.name)) \(correctChallengesCount(for: topic.name)) \(incorrectChallengesCount(for: topic.name))
"""
      print(pp )
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
  
  func totalresetofAllChallengeStatuses(gs:GameState) {
    defer {
      saveChallengeStatuses(stati)
    }
    //if let playData = playData {
    self.stati = [ChallengeStatus](repeating:ChallengeStatus.inReserve, count: playData.gameDatum.flatMap { $0.challenges }.count)
  }
 

  // get challenge at index
//  func getChallenge(row: Int,col:Int) -> Challenge? {
//    let index = row*starting_size+col
//    let chs = everyChallenge
//    guard index >= 0 && index < chs.count else { return nil }
//    return chs[index]
//  }
  

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
  
  // Get the count of allocated challenges for a specific topic name
  func allocatedChallengesCount(for topicName: String) -> Int {
      guard let topicInfo = tinfo[topicName] else {
          print("Warning: Topic \(topicName) not found in tinfo.")
          return 0
      }
      
    return topicInfo.alloccount
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
