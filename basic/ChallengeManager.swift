//
//  ChallengeManager.swift
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
class ChallengeManager{
    internal init(playData: PlayData) {
      self.playData = playData
      self.challengeStatuses = []
    }
  

  private  var challengeStatuses: [ChallengeStatus]  // Using array instead of dictionary
  
  private(set)  var playData: PlayData{
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
          _allChallenges = self.playData.gameDatum.flatMap { $0.challenges }
      }
      // Return the cached value
      return _allChallenges!
  }

  // Cache for allTopics
  private var _allTopics: [String]?
  
  var allTopics: [String] {
      // If _allTopics is nil, compute the value and cache it
      if _allTopics == nil {
          _allTopics = self.playData.topicData.topics.map { $0.name }
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
  
  // Method to set new playData and force reload
  func updatePlayData(_ newPlayData: PlayData) {
      self.playData = newPlayData
  }
 
  func loadAllData  (gameBoard:GameBoard) {
    do {
      if  let gb =  GameBoard.loadGameBoard() {
        gameBoard.cellstate = gb.cellstate
        gameBoard.size = gb.size
        gameBoard.topics = gb.topics
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
    updatePlayData( pd)
      if let loadedStatuses = loadChallengeStatuses() {
        self.challengeStatuses = loadedStatuses
      } else {
        let challenges = pd.gameDatum.flatMap { $0.challenges}
        var cs:[ChallengeStatus] = []
        for j in 0..<challenges.count {
          cs.append(ChallengeStatus(id:challenges[j].id,val:.inReserve))
        }
        self.challengeStatuses = cs
      }
    
     print("Loaded PlayData in \(formatTimeInterval(Date.now.timeIntervalSince(starttime))) secs")
  }

  func saveChallengeStatus( ) {
    saveChallengeStatuses(challengeStatuses)
  }
  
  func getStatus(for challenge:Challenge) throws -> ChallengeStatusVal {
    for index in 0..<challengeStatuses.count {
      if challengeStatuses[index].id == challenge.id { 
        return challengeStatuses[index].val
      }
    }
      throw ChallengeError.notfound
  }
  func setStatus(for challenge:Challenge, status: ChallengeStatusVal) throws {
    defer {
        saveChallengeStatuses(challengeStatuses)
    }
    for (index,cs ) in challengeStatuses.enumerated() {
      if cs.id == challenge.id || cs.val == .inReserve
      {
        challengeStatuses[index] = ChallengeStatus(id:challenge.id,val:status)
        return
      }
    }
    throw ChallengeError.notfound
  }
  
  func allocatedChallengesCount() -> Int {
    return  challengeStatuses.filter { $0.val == .allocated }.count
  }
  
  func freeChallengesCount() -> Int {
    return  challengeStatuses.filter { $0.val  == .inReserve }.count
  }
  
    func resetChallengeStatuses(at challengeIndices: [Int]) {
      defer {
          saveChallengeStatuses(challengeStatuses)
      }
        for index in challengeIndices {
            if index >= 0 && index < challengeStatuses.count {
              challengeStatuses[index].val = .inReserve
            }
        }
    }
  func resetAllChallengeStatuses(gameBoard:GameBoard) {
   
      defer {
          saveChallengeStatuses(challengeStatuses)
      }
      //if let playData = playData {
          self.challengeStatuses = [ChallengeStatus](repeating: ChallengeStatus(id:"??",val:.inReserve), count: playData.gameDatum.flatMap { $0.challenges }.count)
//        } else {
//            self.challengeStatuses = []
//        }
    }

    
    // Allocates N challenges from all challenges
    func allocateChallenges(_ n: Int) -> [Challenge]? {
      defer {
          saveChallengeStatuses(challengeStatuses)
      }
        var allocatedChallenges: [Challenge] = []
        var allocatedCount = 0
        for index in 0..<everyChallenge.count {
          if challengeStatuses[index].val == .inReserve {
            challengeStatuses[index].val = .allocated
                allocatedChallenges.append(everyChallenge[index])
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
    
        var allocatedChallenges: [Challenge] = []
        var allocatedCount = 0
        for index in 0..<everyChallenge.count {
          if everyChallenge[index].topic == topic && challengeStatuses[index].val == .inReserve {
              challengeStatuses[index].val = .allocated
                allocatedChallenges.append(everyChallenge[index])
                allocatedCount += 1
                if allocatedCount == n { break }
            }
        }
        return allocatedCount == n ? allocatedChallenges : nil
    }
    
    // Allocates N challenges nearly evenly from specified topics, taking from any topic in the list if needed
    func allocateChallenges(forTopics topics: [String], count n: Int) -> [Challenge]? {
    
        var topicChallengeMap: [String: [Int]] = [:]
        var allocatedChallenges: [Challenge] = []
        var allocatedCount = 0
        defer {
            saveChallengeStatuses(challengeStatuses)
        }
        // Initialize the topicChallengeMap
        for (index, challenge) in everyChallenge.enumerated() {
          if topics.contains(challenge.topic) && challengeStatuses[index].val == .inReserve {
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
              challengeStatuses[index].val = .allocated
                allocatedChallenges.append(everyChallenge[index])
                allocatedCount += 1
            }
        }
        
        // Allocate any remaining challenges, taking from any available topics
        if allocatedCount < n {
            let additionalChallengesNeeded = n - allocatedCount
            let remainingAvailableChallenges = topics.flatMap { topicChallengeMap[$0] ?? [] }
            for index in remainingAvailableChallenges.prefix(additionalChallengesNeeded) {
              challengeStatuses[index].val = .allocated
                allocatedChallenges.append(everyChallenge[index])
                allocatedCount += 1
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
            saveChallengeStatuses(challengeStatuses)
        }
        // Mark the old challenge as abandoned
      challengeStatuses[index].val = .abandoned
                // Allocate a new challenge from the same topic
        let topic = everyChallenge[index].topic
      let topicChallenges = everyChallenge.enumerated().filter { $0.element.topic == topic && challengeStatuses[$0.offset].val == .inReserve }
        
        guard let newChallengeIndex = topicChallenges.first?.offset else {
            return nil
        }
        
      challengeStatuses[newChallengeIndex].val = .allocated
        return everyChallenge[newChallengeIndex]
    }
    
    
    // Helper functions to get counts
    func allocatedChallengesCount(for topic: Topic) -> Int {
      return countChallenges(for: topic, with:.allocated)
    }
    
    func abandonedChallengesCount(for topic: Topic) -> Int {
      return countChallenges(for: topic, with: .abandoned)
    }
  func correctChallengesCount(for topic: Topic) -> Int {
    return countChallenges(for: topic, with: .playedCorrectly)
  }
  func incorrectChallengesCount(for topic: Topic) -> Int {
    return countChallenges(for: topic, with: .playedIncorrectly)
  }
    
    func freeChallengesCount(for topic: Topic) -> Int {
      return countChallenges(for: topic, with: .inReserve)
    }
    
    func countChallenges(for topic: Topic, with status: ChallengeStatusVal) -> Int {
        let allChallenges = everyChallenge
        return allChallenges.enumerated().filter { index, challenge in
          index < challengeStatuses.count && challenge.topic == topic.name && challengeStatuses[index].val == status
        }.count
    }
}

// MA
