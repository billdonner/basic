//
//  GameBoard.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI

@Observable
class GameState :  Codable {
  var board: [[Challenge]]  // Array of arrays to represent the game board with challenges
  var cellstate: [[ChallengeOutcomes]]  // Array of arrays to represent the state of each cell
  var challengeindices: [[Int]] //into the ChallengeStatuses
  var boardsize: Int  // Size of the game board
  var topicsinplay: [String] // a subset of allTopics (which is constant and maintained in ChaMan)
  var gamestate: StateOfPlay = .initializingApp
  var totaltime: TimeInterval // aka Double
  var playcount:  Int  // woncount + lostcount + abandoned
  var woncount:  Int
  var lostcount:  Int
  var rightcount: Int
  var wrongcount: Int
  var replacedcount: Int
  var faceup:Bool
  var gimmees: Int  // Number of "gimmee" actions available
  var currentscheme: ColorSchemeName
  var veryfirstgame:Bool
  var startincorners:Bool
  var doublediag:Bool
  var difficultylevel:Int
  
  enum CodingKeys: String, CodingKey {
    case _board = "board"
    case _cellstate = "cellstate"
    case _boardsize = "boardsize"
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
    case _challengeindices = "challengeindices"
    case _faceup = "faceup"
    case _currentscheme = "currentscheme"
    case _veryfirstgame = "veryfirstgame"
    case _startincorners = "startincorners"
    case _doublediag = "doublediag"
    case _difficultylevel = "difficultylevel"
  }
  func basicTopics()->[BasicTopic] {
    return topicsinplay.map {BasicTopic(name: $0)}
  }
  init(size: Int, topics: [String], challenges: [Challenge]) {
    
    self.topicsinplay = topics //*****4
    self.boardsize = size
    self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: size), count: size)
    self.cellstate = Array(repeating: Array(repeating: .unplayed, count: size), count: size)
    self.challengeindices = Array(repeating: Array(repeating: -1, count: size), count: size)
    self.gimmees = 0
    self.playcount = 0
    self.woncount = 0
    self.lostcount = 0
    self.rightcount = 0
    self.wrongcount = 0
    self.replacedcount = 0
    self.totaltime = 0.0
    self.faceup = false
    self.currentscheme = .winter
    self.veryfirstgame = true
    self.doublediag = false
    self.difficultylevel = 0
    self.startincorners = false
  }
}

extension GameState {
  func setupForNewGame (boardsize:Int, chmgr:ChaMan) -> Bool {
    // assume all cleaned up, using size
    var allocatedChallengeIndices:[Int] = []
    self.playcount += 1
    self.boardsize = boardsize ///////////////
    self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count:  boardsize), count:   boardsize)
    self.cellstate = Array(repeating: Array(repeating:.unplayed, count: self.boardsize), count: self.boardsize)
    // give player a few gimmees depending on boardsize
    self.gimmees += boardsize - 1
    // use topicsinplay and allocated fresh challenges
    let result:AllocationResult = chmgr.allocateChallenges(forTopics: topicsinplay, count: boardsize * boardsize)
    switch result {
    case .success(let x):
      assert(x.count == boardsize*boardsize)
      print("Success:\(x.count)")
      allocatedChallengeIndices = x.shuffled()
      //continue after the error path
      
    case .error(let err):
      print("Allocation failed for topics \(topicsinplay),count :\(boardsize*boardsize)")
      print ("Error: \(err)")
      switch err {
      case .emptyTopics:
        print("EmptyTopics")
      case .invalidTopics(let names):
        print("Invalid Topics \(names)")
      case .insufficientChallenges:
        print("Insufficient Challenges")
      case .invalidDeallocIndices(let indices):
        print("Indices cant be deallocated \(indices)")
      }
      return false
    }
    // put these challenges into the board
    // set cellstate to unplayed
    for row in 0..<boardsize {
      for col in 0..<boardsize {
        let idxs = allocatedChallengeIndices[row * boardsize + col]
        board[row][col] = chmgr.everyChallenge[idxs]
        cellstate[row][col] = .unplayed
        challengeindices[row][col] = idxs
      }
    }
    gamestate = .playingNow
    saveGameState()
   // print("END OF SETUPFORNEWGAME")
    //chmgr.dumpTopics()
    return true
  }
  
  
  func teardownAfterGame (state:StateOfPlay,chmgr:ChaMan) {
    var challenge_indexes:[Int] = []
    gamestate = state
    // examine each board cell and recycle everything thats unplayed
    for row in 0..<boardsize {
      for col in 0..<boardsize {
        if cellstate[row][col] == .unplayed {
          let idx = challengeindices[row][col]
          if idx != -1 { // hack or not?
            challenge_indexes.append(idx)
          }
        }
      }
    }
    // dealloc at indices first before resetting
    let allocationResult = chmgr.deallocAt(challenge_indexes)
    switch allocationResult {
    case .success(_): break
     // print("dealloc succeeded")
    case .error(let err):
      print("dealloc failed \(err)")
    }
    chmgr.resetChallengeStatuses(at: challenge_indexes)
    saveGameState()
  }
  
  func clearAllCells() {
    for row in 0..<boardsize {
      for col in 0..<boardsize {
        cellstate[row][col] = .unplayed
      }
    }
    saveGameState()
  }
  func dumpGameBoard () {
    print("Dump of GameBoard")
    print("================")
    print("size ",boardsize)
    print("gamestate",gamestate)
    print("gimmees ",gimmees)
    print("totaltime ",totaltime)
    print("topicsinplay ",topicsinplay)
    print("================")
  }
  
  // this returns unplayed challenges and their indices in the challengestatus array
  func resetBoardReturningUnplayed() -> ([Challenge],[Int]) {
    var unplayedChallenges: [Challenge] = []
    var unplayedInts: [Int] = []
    for row in 0..<boardsize {
      for col in 0..<boardsize {
        if cellstate[row][col]  == .unplayed {
          unplayedChallenges.append(board[row][col])
          unplayedInts.append( (row * boardsize + col))
        }
        // cellstate[row][col] = .unplayed
      }
    }
    return (unplayedChallenges,unplayedInts)
  }
  
  func indexOfTopic(_ topic:String ) -> Int? {
   for (index,t) in self.topicsinplay.enumerated()  {
   if t == topic { return index}
   }
   return nil
 }
   func colorForTopic(_ topic:String) ->   (Color, Color, UUID) {
       if let index = indexOfTopic(topic ) {
         //use as into into the selected appcolors sheme
         //let scheme = AppColors.allSchemes[gs.currentscheme.rawValue]
         return AppColors.colorForTopicIndex(index:index,gs:self)
       } else {
         return (Color.white, Color.black, UUID())
       }
     }
  static  func minTopicsForBoardSize(_ size:Int) -> Int {
    switch size  {
    case 3: return 2
    case 4: return 3
    case 5: return 4
    case 6: return 4
    case 7: return 4
    case 8: return 4
    default: return 2
    }
  }
  
  static  func maxTopicsForBoardSize(_ size:Int) -> Int {
    switch size  {
    case 3: return 7
    case 4: return 8
    case 5: return 9
    case 6: return 10
    case 7: return 10
    case 8: return 10
    default: return 7
    }
  }
    
  static  func preselectedTopicsForBoardSize(_ size:Int) -> Int {
    switch size  {
    case 3: return 1
    case 4: return 1
    case 5: return 2
    case 6: return 3
    case 7: return 4
    case 8: return 5
    default: return 1
    }
  }
 
    // Get the file path for storing challenge statuses
    static func getGameStateFileURL() -> URL {
      let fileManager = FileManager.default
      let urls = fileManager.urls(for:.documentDirectory, in: .userDomainMask)
      return urls[0].appendingPathComponent("gameBoard.json")
    }
    
    func saveGameState( ) {
      let filePath = Self.getGameStateFileURL()
      do {
        let data = try JSONEncoder().encode(self)
        try data.write(to: filePath)
      } catch {
        print("Failed to save gs: \(error)")
      }
    }
    // Load the GameBoard
    static func loadGameState() -> GameState? {
      let filePath = getGameStateFileURL()
      do {
        let data = try Data(contentsOf: filePath)
        let gb = try JSONDecoder().decode(GameState.self, from: data)
        return gb
      } catch {
        print("Failed to load gs: \(error)")
        return nil
      }
    }
  
  func isCornerCell(row:Int,col:Int ) -> Bool {
    return row==0&&col==0  ||
    row==0 && col == self.boardsize-1 ||
    row==self.boardsize-1 && col==0 ||
    row==self.boardsize-1 && col == self.boardsize - 1
  }
  
 func isAlreadyPlayed(row:Int,col:Int ) -> (Bool) {
    return ( self.cellstate[row][col] == .playedCorrectly ||
             self.cellstate[row][col] == .playedIncorrectly)
  }
    
  func cellBorderSize() -> CGFloat {
    return CGFloat(11-self.boardsize)*(isIpad ? 3.0:1.0)
    }
  }
