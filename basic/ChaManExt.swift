//
//  ChaManExt.swift
//  basic
//
//  Created by bill donner on 8/1/24.
//

import Foundation

extension ChaMan {
  // Get the file path for storing challenge statuses
  func getChallengeStatusesFilePath() -> URL {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for:.documentDirectory, in: .userDomainMask)
    return urls[0].appendingPathComponent("challengeStatuses.json")
  }
  
  func save() {
    AnsweredInfo.saveAnsweredInfo(ansinfo)
      TopicInfo.saveTopicInfo(tinfo)
      saveChallengeStatuses(stati)
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
  
  
  func loadAllData  (gs:GameState) {
    do {
      if  let gb =  GameState.loadGameState() {
        
        gs.board = gb.board
        gs.cellstate = gb.cellstate
       // gs.challengeindices = gb.challengeindices //!!!
        gs.boardsize = gb.boardsize
        gs.topicsinplay = gb.topicsinplay
        gs.gamestate = gb.gamestate
        gs.totaltime = gb.totaltime
        gs.gamenumber = gb.gamenumber
        gs.rightcount = gb.rightcount
        gs.wrongcount = gb.wrongcount
        gs.lostcount = gb.lostcount
        gs.woncount = gb.woncount
        gs.replacedcount = gb.replacedcount
        gs.faceup = gb.faceup
        gs.gimmees = gb.gimmees
        gs.currentscheme = gb.currentscheme
        gs.veryfirstgame = gb.veryfirstgame
        gs.startincorners = gb.startincorners
        gs.doublediag = gb.doublediag
        gs.difficultylevel = gb.difficultylevel
        gs.movenumber = gb.movenumber
        gs.moveindex = gb.moveindex
      }
      try self.loadPlayData(from: playDataFileName)
      
    } catch {
      print("Failed to load PlayData: \(error)")
    }
    checkAllTopicConsistency("chaman loaddata")
  }

  // Helper functions to get counts
  func allocatedChallengesCount() -> Int {
    return  stati.filter { $0 == .allocated }.count
  }
  
  func freeChallengesCount() -> Int {
    return  stati.filter { $0   == .inReserve }.count
  }
  
  func abandonedChallengesCount() -> Int {
    return  stati.filter { $0   == .abandoned }.count
  }
  func correctChallengesCount() -> Int {
    return  stati.filter { $0   == .playedCorrectly }.count
  }
  func incorrectChallengesCount() -> Int {
    return  stati.filter { $0   == .playedIncorrectly }.count
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

extension ChaMan {
  
  
  // Verify that tinfo and stati arrays are in sync
  func verifySync() -> Bool {
    for (topicName, topicInfo) in tinfo {
      var calculatedFreeCount = 0
      for index in topicInfo.challengeIndices {
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
  func checkSingleTopicConsistency(_ topic:String,_ message:String) {
    
    let ti = tinfo[topic]
    assert(ti != nil)
    let t = ti!
    let free = freeChallengesCount(for:topic)
    let alloc = allocatedChallengesCount(for:topic)
    let abandon = abandonedChallengesCount(for:topic)
    let correct = correctChallengesCount(for:topic)
    let incorrect = incorrectChallengesCount(for:topic)
    assert(free == t.freecount,"\(message) \(topic) free \(free) != \(t.freecount)")
    assert(alloc == t.alloccount,"\(message) \(topic) alloc \(alloc) != \(t.alloccount)")
    assert(abandon == t.replacedcount,"\(message) \(topic) abandon \(abandon) != \(t.replacedcount)")
    assert(correct == t.rightcount,"\(message) \(topic) correct \(correct) != \(t.rightcount)")
    assert(incorrect == t.wrongcount,"\(message) \(topic) incorrect \(incorrect) != \(t.wrongcount)")
  }
  func checkAllTopicConsistency(_ message:String) {
    // assert( verifySync(),"\(message) sync")

    var freecount = 0
    let freeFromStati = freeChallengesCount()
    var alloccount = 0
    let allocFromStati = allocatedChallengesCount()
    var abandoncount = 0
    let abandonFromStati = abandonedChallengesCount()
    var correctcount =  0
    let correctFromStati = correctChallengesCount()
    var incorrectcount = 0
    let incorrectFromStati = incorrectChallengesCount()
    
    for t in  playData.topicData.topics {
      checkSingleTopicConsistency(t.name,message)
      freecount += freeChallengesCount(for:t.name)
      alloccount += allocatedChallengesCount(for:t.name)
      abandoncount += abandonedChallengesCount(for:t.name)
      correctcount += correctChallengesCount(for:t.name)
      incorrectcount +=  incorrectChallengesCount(for:t.name)
    }
    assert(abandoncount == abandonFromStati,"\(message) abandoncount \(abandoncount) not \(abandonFromStati)")
    assert(correctcount == correctFromStati,"\(message) correctcount \(correctcount) not \(correctFromStati)")
    assert(incorrectcount == incorrectFromStati,"\(message) incorrectcount \(incorrectcount) not \(incorrectFromStati)")
    assert(freecount ==  freeFromStati,"\(message) freecount\(freecount) not \(freeFromStati)")
    assert(alloccount == allocFromStati ,"\(message) alloccount\(alloccount) not \(allocFromStati)")
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
  

    func dumpStati(_ mess:String){
      var counter = 0
      print("Dump status \(mess)")
      print("==========================")
      for (idx,sta) in stati.enumerated() {
        if sta != .inReserve {
          print (" \(idx) \(sta)")
          counter += 1
        }
      }
      print("\(counter) allocated or played out of \(stati.count)")
    }
}


