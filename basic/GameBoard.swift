//
//  GameBoard.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
@Observable
class GameBoard : ObservableObject, Codable {
  var board: [[Challenge]]  // Array of arrays to represent the game board with challenges
  var cellstate: [[ChallengeOutcomes]]  // Array of arrays to represent the state of each cell
  var size: Int  // Size of the game board
  var topics: [String]  // List of topics for the game
  var gimmees: Int  // Number of "gimmee" actions available
  var gamestate: GameState = .initializingApp
  var playcount:  Int  // woncount + lostcount + abandoned
  var woncount:  Int
  var lostcount:  Int
  var rightcount: Int
  var wrongcount: Int
  var replacedcount: Int
  var totaltime: TimeInterval // aka Double
  var topicsinplay: [String] // a subset of allTopics which is constant and maintained in ChallengeManager
  
  enum CodingKeys: String, CodingKey {
    case _board = "board"
    case _cellstate = "cellstate"
    case _topics = "topics"
    case _size = "selected"
    case _gimmees = "gimmees"
    case _gamestate = "gamestate"
    case _playcount = "playcount"
    case _woncount = "woncount"
    case _lostcount = "lostcount"
    case _rightcount = "rightcount"
    case _wrongcount = "wrongcount"
    case _replacedcount = "replacedcount"
    case _totaltime = "totaltime"
    case _topicsinplay = "topicsinplay"
    
  }
  
  init(size: Int, topics: [String], challenges: [Challenge]) {
    self.size = size
    self.topics = topics
    self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: size), count: size)
    self.cellstate = Array(repeating: Array(repeating: .unplayed, count: size), count: size)
    self.gimmees = 0
    self.playcount = 0
    self.woncount = 0
    self.lostcount = 0
    self.rightcount = 0
    self.wrongcount = 0
    self.replacedcount = 0
    self.totaltime = 0.0
    self.topicsinplay = []
    populateBoard(with: challenges)
  }
}
extension GameBoard {
  
  func saveGameBoard( ) {
    let filePath = getGameBoardFilePath()
    do {
      let data = try JSONEncoder().encode(self)
      try data.write(to: filePath)
    } catch {
      print("Failed to save gameboard: \(error)")
    }
  }
  // Load the GameBoard
  static func loadGameBoard() -> GameBoard? {
    let filePath = getGameBoardFilePath()
    do {
      let data = try Data(contentsOf: filePath)
      let gb = try JSONDecoder().decode(GameBoard.self, from: data)
      return gb
    } catch {
      print("Failed to load gameboard: \(error)")
      return nil
    }
  }
  // add Persistence to GameBoard
  
  func populateBoard(with challenges: [Challenge]) {
    var challengeIndex = 0
    for row in 0..<size {
      for col in 0..<size {
        if challengeIndex < challenges.count {
          board[row][col] = challenges[challengeIndex]
          cellstate[row][col] = .unplayed
          challengeIndex += 1
        }
      }
    }
  }
  
  func   reinit(size: Int, topics: [String], challenges: [Challenge],dontPopulate:Bool = false){
    self.playcount += 1
    self.size = size
    self.topics = topics
    self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: self.size), count:  self.size)
    self.cellstate = Array(repeating: Array(repeating:.unplayed, count: self.size), count: self.size)
    if !dontPopulate { populateBoard(with: challenges) }
  }

  // this returns unplayed challenges and their indices in the challengestatus array
  func resetBoardReturningUnplayed() -> ([Challenge],[Int]) {
    var unplayedChallenges: [Challenge] = []
    var unplayedInts: [Int] = []
    for row in 0..<size {
      for col in 0..<size {
        if cellstate[row][col]  == .unplayed {
          unplayedChallenges.append(board[row][col])
          unplayedInts.append( (row * size + col))
        }
       // cellstate[row][col] = .unplayed
      }
    }
    return (unplayedChallenges,unplayedInts)
  }
  
  func replaceChallenge(at position: (Int, Int), with newChallenge: Challenge) {
    let (row, col) = position
    if row >= 0 && row < size && col >= 0 && col < size {
      board[row][col] = newChallenge
      cellstate[row][col] = .unplayed // probably dont need this
    }
  }
  
  func getUnplayedChallenges() -> [Challenge] {
    var unplayedChallenges: [Challenge] = []
    for row in 0..<size {
      for col in 0..<size {
        if cellstate[row][col] == .unplayed {
          unplayedChallenges.append(board[row][col])
        }
      }
    }
    return unplayedChallenges
  }
  static  func minTopicsForBoardSize(_ size:Int) -> Int {
    switch size  {
    case 3: return 2
    case 4: return 3
    case 5: return 4
    case 6: return 4
    default: return 2
    }
  }
  
  static  func maxTopicsForBoardSize(_ size:Int) -> Int {
    switch size  {
    case 3: return 7
    case 4: return 8
    case 5: return 9
    case 6: return 10
    default: return 7
    }
  }
  
  func windDown(_ status: GameState, challengeManager:ChallengeManager) {
    let (_,unplayedIndices) = self.resetBoardReturningUnplayed()
    challengeManager.resetChallengeStatuses(at: unplayedIndices)
    challengeManager.saveChallengeStatus()
    self.gamestate = status
    self.saveGameBoard()
  }
  
}
