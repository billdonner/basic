//
//  GameBoard.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
@Observable
class GameBoard :  Codable {
  

  func setupForNewGame (chmgr:ChaMan) -> Bool {
    // assume all cleaned up, using size
    var allocatedChallenges:[Challenge] = []
    self.playcount += 1
    self.size = size
    self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: self.size), count:  self.size)
    self.cellstate = Array(repeating: Array(repeating:.unplayed, count: self.size), count: self.size)
    
    // use topicsinplay and allocated fresh challenges
    let result:AllocationResult = chmgr.allocateChallenges(forTopics: topicsinplay, count: size * size)
    switch result {
    case .success(let x):
      print("Success:\(x.count)")
      allocatedChallenges=x
      
      //continue after the error path
      
    case .error(let err):
      print("Allocation failed for topics \(topicsinplay),count :\(size*size)")
      print ("Error: \(err)")
      switch err {
      case .emptyTopics:
        print("EmptyTopics")
      case .invalidTopics(let names):
        print("Invalid Topics \(names)")
      case .insufficientChallenges:
        print("Insufficient Challenges")
      }
      return false
    }
    
    
    // put these challenges into the board
    // set cellstate to unplayed
    for row in 0..<size {
      for col in 0..<size {
        board[row][col] = allocatedChallenges[row * size + col]
        cellstate[row][col] = .unplayed
      }
    }
    gamestate = .playingNow
    saveGameBoard()
    print("END OF SETUPFORNEWGAME")
    chmgr.dumpTopics()
    return true
  }


func teardownAfterGame (state:GameState,chmgr:ChaMan) {
  var challenge_indexes:[Int] = []
  gamestate = state
  // examine each board cell and recycle everything thats unplayed
  for row in 0..<size {
    for col in 0..<size {
      if cellstate[row][col] == .unplayed {
        challenge_indexes.append(row*size+col)
      }
    }
  }
  // return stuff
  chmgr.resetChallengeStatuses(at: challenge_indexes)
  saveGameBoard()
}

func clearAllCells() {
  for row in 0..<size {
    for col in 0..<size {
      cellstate[row][col] = .unplayed
      
    }
  }
  saveGameBoard()
}
func dumpGameBoard () {
  print("Dump of GameBoard")
  print("================")
  print("size ",size)
  print("gamestate",gamestate)
  print("gimmees ",gimmees)
  print("totaltime ",totaltime)
  print("topicsinplay ",topicsinplay)
  print("================")
}


var board: [[Challenge]]  // Array of arrays to represent the game board with challenges
var cellstate: [[ChallengeOutcomes]]  // Array of arrays to represent the state of each cell
var size: Int  // Size of the game board
var topicsinplay: [String] // a subset of allTopics (which is constant and maintained in ChaMan)
var gamestate: GameState = .initializingApp
var totaltime: TimeInterval // aka Double
var playcount:  Int  // woncount + lostcount + abandoned
var woncount:  Int
var lostcount:  Int
var rightcount: Int
var wrongcount: Int
var replacedcount: Int
var gimmees: Int  // Number of "gimmee" actions available


enum CodingKeys: String, CodingKey {
  case _board = "board"
  case _cellstate = "cellstate"
  case _size = "size"
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
  self.topicsinplay = topics //*****4
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
  //populateBoard(with: challenges)
  print("//*****5")
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
  
  //  func windDown(_ status: GameState, chmgr:ChaMan) {
  //    print("//GameBoard windown")
  //    let (_,unplayedIndices) = self.resetBoardReturningUnplayed()
  //    chmgr.resetChallengeStatuses(at: unplayedIndices)
  //    chmgr.saveChallengeStatus()
  //    self.gamestate = status
  //    self.saveGameBoard()
  //  }
  
}
