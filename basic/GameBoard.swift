//
//  GameBoard.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
// MARK: - Modified GameBoard Class

class GameBoard {
    var board: [[Challenge]]
    var status: [[ChallengeStatus]]
    var size: Int
    var topics: [String]
    
    init(size: Int, topics: [String], challenges: [Challenge]) {
      
      func populateBoard(with challenges: [Challenge]) {
          var challengeIndex = 0
          for row in 0..<size {
              for col in 0..<size {
                  if challengeIndex < challenges.count {
                      board[row][col] = challenges[challengeIndex]
                      status[row][col] = ChallengeStatus(id:challenges[challengeIndex].id,val:.allocated)
                      challengeIndex += 1
                  }
              }
          }
      }
        self.size = size
        self.topics = topics
        self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: size), count: size)
         self.status = Array(repeating: Array(repeating: ChallengeStatus(id:"",val:.inReserve), count: size), count: size)
        populateBoard(with: challenges)
    }
    

    
    func resetBoard() -> [Challenge] {
        var unplayedChallenges: [Challenge] = []
        for row in 0..<size {
            for col in 0..<size {
              if status[row][col].val == .allocated {
                    unplayedChallenges.append(board[row][col])
                status[row][col] = ChallengeStatus(id:"",val:.inReserve)
                }
            }
        }
        return unplayedChallenges
    }
    
    func replaceChallenge(at position: (Int, Int), with newChallenge: Challenge) {
        let (row, col) = position
        if row >= 0 && row < size && col >= 0 && col < size {
            board[row][col] = newChallenge
          status[row][col] = ChallengeStatus(id:newChallenge.id,val:.allocated)
        }
    }
    
    func getUnplayedChallenges() -> [Challenge] {
        var unplayedChallenges: [Challenge] = []
        for row in 0..<size {
            for col in 0..<size {
              if status[row][col].val == .allocated {
                    unplayedChallenges.append(board[row][col])
                }
            }
        }
        return unplayedChallenges
    }
}

