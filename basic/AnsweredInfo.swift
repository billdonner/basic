//
//  AnsweredInfo.swift
//  basic
//
//  Created by bill donner on 8/3/24.
//

import Foundation

struct AnsweredInfo: Codable {
  internal init(id: String, answer: String, outcome: ChaMan.ChallengeStatus, timestamp: Date, timetoanswer: TimeInterval, gamenumber: Int, movenumber: Int, row: Int, col: Int) {
    self.id = id
    self.answer = answer
    self.outcome = outcome
    self.timestamp = timestamp
    self.timetoanswer = timetoanswer
    self.gamenumber = gamenumber
    self.movenumber = movenumber
    self.row = row
    self.col = col
  }
  

  
  let id:String //id of the challenge
  let answer:String //answer given
  let outcome:ChaMan.ChallengeStatus
  let timestamp: Date
  let timetoanswer: TimeInterval
  let gamenumber: Int
  let movenumber: Int
  let row: Int
  let col: Int

  func checkConsistency() {
    assert (outcome == .playedCorrectly || outcome == .playedCorrectly || outcome == .abandoned)
  }
  // Get the file path for storing challenge statuses
  static func getAnsweredInfoFilePath() -> URL {
      let fileManager = FileManager.default
      let urls = fileManager.urls(for:.documentDirectory, in: .userDomainMask)
      return urls[0].appendingPathComponent("answeredinfo.json")
  }
  static func saveAnsweredInfo (_ info:[String:AnsweredInfo]) {
    let filePath = Self.getAnsweredInfoFilePath()
      do {
          let data = try JSONEncoder().encode(info)
          try data.write(to: filePath)
      } catch {
          print("Failed to save AnsweredInfo: \(error)")
      }
  }
  // Load  from a file
  static func loadAnsweredInfo() -> [String:AnsweredInfo]? {
    let filePath = getAnsweredInfoFilePath()
      do {
          let data = try Data(contentsOf: filePath)
          let dict = try JSONDecoder().decode([String:AnsweredInfo].self, from: data)
          return dict
      } catch {
          print("Failed to load AnsweredInfo: \(error)")
          return nil
      }
  }
  static func dumpAnsweredInfo(info:[String:AnsweredInfo]) {
        for (index,inf) in info.enumerated() {
          let tinfo:AnsweredInfo =    inf.value
          print("\(index): \(inf.key) \(tinfo.answer) \(tinfo.timestamp) \(tinfo.timetoanswer) \(tinfo.gamenumber) \(tinfo.movenumber  )")
        }
  }
  
  private enum CodingKeys: CodingKey {
    case id
    case answer
    case outcome
    case timestamp
    case timetoanswer
    case gamenumber
    case movenumber
    case row
    case col
  }
  
  init(from decoder: any Decoder) throws {
    let container: KeyedDecodingContainer<AnsweredInfo.CodingKeys> = try decoder.container(keyedBy: AnsweredInfo.CodingKeys.self)
    
    self.id = try container.decode(String.self, forKey: AnsweredInfo.CodingKeys.id)
    self.answer = try container.decode(String.self, forKey: AnsweredInfo.CodingKeys.answer)
    self.outcome = try container.decode(ChaMan.ChallengeStatus.self, forKey: AnsweredInfo.CodingKeys.outcome)
    self.timestamp = try container.decode(Date.self, forKey: AnsweredInfo.CodingKeys.timestamp)
    self.timetoanswer = try container.decode(TimeInterval.self, forKey: AnsweredInfo.CodingKeys.timetoanswer)
    self.gamenumber = try container.decode(Int.self, forKey: AnsweredInfo.CodingKeys.gamenumber)
    self.movenumber = try container.decode(Int.self, forKey: AnsweredInfo.CodingKeys.movenumber)
    self.row = try container.decode(Int.self, forKey: AnsweredInfo.CodingKeys.row)
    self.col = try container.decode(Int.self, forKey: AnsweredInfo.CodingKeys.col)
    
  }
  
  func encode(to encoder: any Encoder) throws {
    var container: KeyedEncodingContainer<AnsweredInfo.CodingKeys> = encoder.container(keyedBy: AnsweredInfo.CodingKeys.self)
    
    try container.encode(self.id, forKey: AnsweredInfo.CodingKeys.id)
    try container.encode(self.answer, forKey: AnsweredInfo.CodingKeys.answer)
    try container.encode(self.outcome, forKey: AnsweredInfo.CodingKeys.outcome)
    try container.encode(self.timestamp, forKey: AnsweredInfo.CodingKeys.timestamp)
    try container.encode(self.timetoanswer, forKey: AnsweredInfo.CodingKeys.timetoanswer)
    try container.encode(self.gamenumber, forKey: AnsweredInfo.CodingKeys.gamenumber)
    try container.encode(self.movenumber, forKey: AnsweredInfo.CodingKeys.movenumber)
    try container.encode(self.row, forKey: AnsweredInfo.CodingKeys.row)
    try container.encode(self.col, forKey: AnsweredInfo.CodingKeys.col)
  }
}
extension ChaMan {
  func setupAnsweredInfo() {
    ansinfo = [:]
  }
}
