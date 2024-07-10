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
  var playcount:  Int  
  
  enum CodingKeys: String, CodingKey {
    case _board = "board"
    case _cellstate = "cellstate"
    case _topics = "topics"
    case _size = "selected"
    case _gimmees = "gimmees"
    case _gamestate = "gamestate"
    case _playcount = "playcount"
  }
  
  init(size: Int, topics: [String], challenges: [Challenge]) {
    self.size = size
    self.topics = topics
    self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: size), count: size)
    self.cellstate = Array(repeating: Array(repeating: .unplayed, count: size), count: size)
    self.gimmees = 0
    self.playcount = 0
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
  func loadGameBoard() -> GameBoard? {
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
  
  func   reinit(size: Int, topics: [String], challenges: [Challenge]){
    self.playcount += 1
    self.size = size
    self.topics = topics
    self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: size), count: size)
    self.cellstate = Array(repeating: Array(repeating:.unplayed, count: size), count: size)
    populateBoard(with: challenges)
  }
  
  
  
  
  // this returns unplayed challenges
  func resetBoardReturningUnplayed() -> [Challenge] {
    var unplayedChallenges: [Challenge] = []
    for row in 0..<size {
      for col in 0..<size {
        if cellstate[row][col]  == .unplayed {
          unplayedChallenges.append(board[row][col])
        }
       // cellstate[row][col] = .unplayed
      }
    }
    return unplayedChallenges
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
}
