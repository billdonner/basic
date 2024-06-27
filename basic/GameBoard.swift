//
//  GameBoard.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI

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
    self.size = size
    self.topics = topics
    self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: size), count: size)
    self.cellstate = Array(repeating: Array(repeating:.unplayed, count: size), count: size)
    populateBoard(with: challenges)
  }
  
  static var mock = {
    GameBoard(size:1,topics:["Fun"],challenges:[Challenge.complexMock])
  }
  

  
  // this returns unplayed challenges
  func resetBoardReturningUnplayed() -> [Challenge] {
    var unplayedChallenges: [Challenge] = []
    for row in 0..<size {
      for col in 0..<size {
        if cellstate[row][col]  == .unplayed {
          unplayedChallenges.append(board[row][col])
        }
        cellstate[row][col] = .unplayed
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
}

