//
//  TopicInfo.swift
//  basic
//
//  Created by bill donner on 7/31/24.
//

import Foundation
struct TopicInfo : Codable {
      let name: String
      var alloccount: Int
      var freecount: Int
      var replacedcount: Int
      var rightcount: Int
      var wrongcount: Int
      var challengeIndices: [Int] // indexes into stati

  func checkConsistency() {
    assert (alloccount + freecount + replacedcount + rightcount + wrongcount == challengeIndices.count)
  }
  func getChallengesAndStatuses (chmgr:ChaMan)-> ([Challenge],[ChaMan.ChallengeStatus]) {
    checkConsistency()
    var challenges:[Challenge] = []
    var statuses:[ChaMan.ChallengeStatus] = []
    for challengeIdx in self.challengeIndices {
      challenges.append (chmgr.everyChallenge[challengeIdx])
      statuses.append (chmgr.stati[challengeIdx])
    }
    return (challenges,statuses)
  }
  
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
  
  static func dumpTopicInfo(info:[String:TopicInfo]) {
 
        for (index,inf) in info.enumerated() {
          let tinfo:TopicInfo =    inf.value
          print("\(index): \(inf.key) \(tinfo.challengeIndices.count)")
        }
  
  }
}

extension ChaMan {
  
  func setupTopicInfo(){
    // calculate free counts by topic
    var freeCountByTopic: [String: Int] = [:]
    var challengesByTopic: [String:[Int]] = [:]

    // Iterate through all challenges and count free ones
    for (index, challenge) in everyChallenge.enumerated() {
      if stati[index] == .inReserve {
        freeCountByTopic[challenge.topic, default: 0] += 1
        challengesByTopic[challenge.topic, default: []] += [index]
      } else  {
        fatalError()
      }
    }
    
    // back thru all the topics
    for topic in playData.topicData.topics {
      let ti = TopicInfo(name: topic.name, alloccount:  0,
                         freecount: freeCountByTopic[topic.name ] ?? 0,
                         replacedcount:0,
                         rightcount: 0,
                         wrongcount: 0,
                         challengeIndices: challengesByTopic[topic.name] ?? [])
      tinfo[topic.name] = ti

    }

  }
  
}
