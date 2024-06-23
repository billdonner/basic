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
        self.size = size
        self.topics = topics
        self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: size), count: size)
        self.status = Array(repeating: Array(repeating: .inReserve, count: size), count: size)
        populateBoard(with: challenges)
    }
    
    func populateBoard(with challenges: [Challenge]) {
        var challengeIndex = 0
        for row in 0..<size {
            for col in 0..<size {
                if challengeIndex < challenges.count {
                    board[row][col] = challenges[challengeIndex]
                    status[row][col] = .allocated
                    challengeIndex += 1
                }
            }
        }
    }
    
    func resetBoard() -> [Challenge] {
        var unplayedChallenges: [Challenge] = []
        for row in 0..<size {
            for col in 0..<size {
                if status[row][col] == .allocated {
                    unplayedChallenges.append(board[row][col])
                    status[row][col] = .inReserve
                }
            }
        }
        return unplayedChallenges
    }
    
    func replaceChallenge(at position: (Int, Int), with newChallenge: Challenge) {
        let (row, col) = position
        if row >= 0 && row < size && col >= 0 && col < size {
            status[row][col] = .abandoned
            board[row][col] = newChallenge
            status[row][col] = .allocated
        }
    }
    
    func getUnplayedChallenges() -> [Challenge] {
        var unplayedChallenges: [Challenge] = []
        for row in 0..<size {
            for col in 0..<size {
                if status[row][col] == .allocated {
                    unplayedChallenges.append(board[row][col])
                }
            }
        }
        return unplayedChallenges
    }
}
