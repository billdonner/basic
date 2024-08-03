//
//  ChaMan.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import Foundation


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
  
  func allocateChallenges(forTopics topics: [String], count n: Int) -> AllocationResult {
    var allocatedChallengeIndices: [Int] = []
    var topicIndexes: [String: [Int]] = [:]
    var tinfobuffer: [String: TopicInfo] = tinfo
    
    func fixup(_ topic: String, _ topicIndexes: inout [String : [Int]], _ allocatedIndexes: Array<Int>.SubSequence) {
      // Update tinfo to keep it in sync
      if var topicInfo = tinfo[topic] {
        topicInfo.freecount -= allocatedIndexes.count
        topicInfo.alloccount += allocatedIndexes.count
        tinfobuffer[topic] = topicInfo
        topicInfo.checkConsistency()
      }
    }
   // dumpStati("allocateChallenges start")
    checkAllTopicConsistency("allocateChallenges start")
    // Defensive check for empty topics array
    guard !topics.isEmpty else {
      return .error(.emptyTopics)
    }
    
    // Populate the dictionary with indexes inReserve for each specified topic
    for topic in topics {
      if let topicInfo = tinfo[topic] {
        let idxs:[Int]=topicInfo.challengeIndices.compactMap{stati[$0] == .inReserve ? $0 : nil}
      topicIndexes[topic] = idxs
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
        fixup(topic, &topicIndexes, allocatedIndexes)
        checkSingleTopicConsistency(topic,"First pass")
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
        fixup(topic, &topicIndexes, allocatedIndexes)
        checkSingleTopicConsistency(topic,"Second pass")
      }
    }
    
    // Third pass: If still not enough challenges, take from any available topic
    if allocatedChallengeIndices.count < n {
      for (topic, info) in tinfo {
        if !topics.contains(topic) { // Skip specified topics since they have already been considered
          let nindexes = info.challengeIndices
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
            fixup(topic, &topicIndexes, allocatedIndexes)
            checkSingleTopicConsistency(topic,"Third pass")
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
    //if we got this far
    tinfo = tinfobuffer
    //dumpStati("allocateChallenges end")
    checkAllTopicConsistency("allocateChallenges end")
    save()
    return .success(allocatedChallengeIndices)//.shuffled()) // see if this works
  }
  func deallocAt(_ indexes: [Int]) -> AllocationResult {
    var topicIndexes: [String: [Int]] = [:]
    var invalidIndexes: [Int] = []
    var tinfobuffer: [String: TopicInfo] = tinfo
    checkAllTopicConsistency("dealloc  start")
    
   // dumpStati("deallcx start")
    
    //print("-----Deallocating Challenge Indices: \(indexes)")
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
        // Remove indexes from topicInfo.ch and move them to the end
        for index in indexes {
          if let pos = topicInfo.challengeIndices.firstIndex(of: index) {
            topicInfo.challengeIndices.remove(at: pos)
            topicInfo.challengeIndices.append(index) // Move to the end
          }
        }
        topicInfo.freecount += indexes.count
        topicInfo.alloccount -= indexes.count
        // Update tinfo to keep it in sync
        //tinfo[topic] = topicInfo
        tinfobuffer[topic] = topicInfo
        topicInfo.checkConsistency()
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
    tinfo = tinfobuffer
    save()
    checkAllTopicConsistency("deallc end")
    //dumpStati("deallcx end")
    return .success([])
  }
  
  // Replace a challenge at a specific index and update internal structures
  func replaceChallenge(at index: Int) -> AllocationResult {
    guard index < everyChallenge.count else {
      return .error(.invalidTopics(["Invalid index: \(index)"]))
    }
    
    let challenge = everyChallenge[index]
    let topic = challenge.topic // Assuming `Challenge` has a `topic` property
    
    
    // Find a new challenge to replace the old one
    if var topicInfo = tinfo[topic] {
      if let newChallengeIndex = topicInfo.challengeIndices.last(where: { stati[$0] == .inReserve }) {
        let newChallenge = everyChallenge[newChallengeIndex]
        // swap the actual challenges
        everyChallenge[index] = newChallenge
        everyChallenge[newChallengeIndex] = challenge
        print("replaceChallenge at \(index) with challenge at \(newChallengeIndex)")
        stati[newChallengeIndex] = .abandoned
        print("marking \(newChallengeIndex) as abandoned")
        print("status of \(index) is \(stati[index])")
        
        // dont need to change the indices because we swapped challenges
        
        topicInfo.replacedcount += 1
        topicInfo.freecount -= 1
        tinfo[topic] = topicInfo
        save()
        // Return the index of the we supplied
        checkAllTopicConsistency("replaceChallenge end")
        return .success([index])
      } else {
        return .error(.insufficientChallenges)
      }
    } else {
      return .error(.invalidTopics([topic]))
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
    
    if let loadedTinfo = TopicInfo.loadTopicInfo() {
      self.tinfo = loadedTinfo
    } else {
      self.tinfo = [:]
      setupTopicInfo() // build from scratch
    }
    
    //    dumpTopics()
    //    TopicInfo.dumpTopicInfo(info: tinfo)
    print("Loaded \(self.stati.count) challenges from PlayData in \(formatTimeInterval(Date.now.timeIntervalSince(starttime))) secs")
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
  
  
  func bumpWrongcount(topic:String){
    if var t =  tinfo[topic] {
      t.wrongcount += 1
      t.alloccount -= 1
      tinfo[topic] = t
    }
    TopicInfo.saveTopicInfo(tinfo)
  }
  func bumpRightcount(topic:String){
    if var t =  tinfo[topic] {
      t.rightcount += 1
      t.alloccount -= 1
      tinfo[topic] = t
    }
    TopicInfo.saveTopicInfo(tinfo)
  }
  
}
