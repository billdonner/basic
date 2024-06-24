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
class ChallengeManager : ObservableObject {
    internal init(playData: PlayData? = nil) {
        self.playData = playData
      self.challengeStatuses = []
    }
    
    var playData: PlayData?
    var challengeStatuses: [ChallengeStatus]  // Using array instead of dictionary
    
  func setStatus(for challenge:Challenge, status: ChallengeStatusVal) throws {
    defer {
        saveChallengeStatuses(challengeStatuses)
    }
    for (index,cs ) in challengeStatuses.enumerated() {
      if cs.id == challenge.id || cs.val == .inReserve {
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
    func resetAllChallengeStatuses() {
      defer {
          saveChallengeStatuses(challengeStatuses)
      }
        if let playData = playData {
          self.challengeStatuses = [ChallengeStatus](repeating: ChallengeStatus(id:"??",val:.inReserve), count: playData.gameDatum.flatMap { $0.challenges }.count)
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
      defer {
          saveChallengeStatuses(challengeStatuses)
      }
        let allChallenges = getAllChallenges()
        var allocatedChallenges: [Challenge] = []
        var allocatedCount = 0
        for index in 0..<allChallenges.count {
          if challengeStatuses[index].val == .inReserve {
            challengeStatuses[index].val = .allocated
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
          if allChallenges[index].topic == topic && challengeStatuses[index].val == .inReserve {
              challengeStatuses[index].val = .allocated
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
                allocatedChallenges.append(allChallenges[index])
                allocatedCount += 1
            }
        }
        
        // Allocate any remaining challenges, taking from any available topics
        if allocatedCount < n {
            let additionalChallengesNeeded = n - allocatedCount
            let remainingAvailableChallenges = topics.flatMap { topicChallengeMap[$0] ?? [] }
            for index in remainingAvailableChallenges.prefix(additionalChallengesNeeded) {
              challengeStatuses[index].val = .allocated
                allocatedChallenges.append(allChallenges[index])
                allocatedCount += 1
            }
        }
        
      return allocatedCount == n ? allocatedChallenges.shuffled() : nil
    }
    // get challenge at index
  func getChallenge(row: Int,col:Int) -> Challenge? {
    let index = row*starting_size+col 
    let chs = getAllChallenges()
    guard index >= 0 && index < chs.count else { return nil }
    return chs[index]
  }
  
    // Replaces one challenge with another, marking the old one as abandoned
    func replaceChallenge(at index: Int) -> Challenge? {
        guard index >= 0 && index < getAllChallenges().count else { return nil }
        defer {
            saveChallengeStatuses(challengeStatuses)
        }
        // Mark the old challenge as abandoned
      challengeStatuses[index].val = .abandoned
        
        // Allocate a new challenge from the same topic
        let topic = getAllChallenges()[index].topic
      let topicChallenges = getAllChallenges().enumerated().filter { $0.element.topic == topic && challengeStatuses[$0.offset].val == .inReserve }
        
        guard let newChallengeIndex = topicChallenges.first?.offset else {
            return nil
        }
        
      challengeStatuses[newChallengeIndex].val = .allocated
        return getAllChallenges()[newChallengeIndex]
    }
    
    
    // Helper functions to get counts
    func allocatedChallengesCount(for topic: Topic) -> Int {
      return countChallenges(for: topic, with:.allocated)
    }
    
    func abandonedChallengesCount(for topic: Topic) -> Int {
      return countChallenges(for: topic, with: .abandoned)
    }
    
    func freeChallengesCount(for topic: Topic) -> Int {
      return getAllChallenges().enumerated().filter { $0.element.topic == topic.name && challengeStatuses[$0.offset].val == .inReserve }.count
    }
    
    func countChallenges(for topic: Topic, with status: ChallengeStatusVal) -> Int {
        let allChallenges = getAllChallenges()
        return allChallenges.enumerated().filter { index, challenge in
          index < challengeStatuses.count && challenge.topic == topic.name && challengeStatuses[index].val == status
        }.count
    }
}

// MA
