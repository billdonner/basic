//
//  GameState.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
struct GameMove : Codable {
  let row:Int
  let col:Int
}

@Observable
class GameState :  Codable {
  var board: [[Int]]  // Array of arrays to represent the game board with challenges
  var cellstate: [[ChallengeOutcomes]]  // Array of arrays to represent the state of each cell 
  var boardsize: Int  // Size of the game board
  var topicsinplay: [String] // a subset of allTopics (which is constant and maintained in ChaMan)
  var gamestate: StateOfPlay = .initializingApp
  var totaltime: TimeInterval // aka Double
  var gamenumber:  Int
  var movenumber:  Int
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
  var lastmove: GameMove?
  var moveindex: [[Int]] // -1 is unplayed
  var onwinpath: [[Bool]] // only set after win detected
  var replaced:[[[Int]]] // list of replacements in this cell
  
  
  func checkVsChaMan(chmgr:ChaMan) -> Bool {
    let a=chmgr.correctChallengesCount()
    if a != rightcount {
      print("*** correct challenges count \(a) is wrong \(rightcount)")
      return false
    }
    let b = chmgr.incorrectChallengesCount()
    if b != wrongcount {
      print("*** incorrect challenges count \(b) is wrong \(wrongcount)")
      
      return false
    }
    if gamestate != .initializingApp { 
      // check everything on the board is consistent
      
      for row in  0 ..< boardsize  {
        for col in 0 ..< boardsize  {
          
          let j = board[row][col]
          if j != -1 {
            let x:ChaMan.ChallengeStatus = chmgr.stati[j]
            switch cellstate[row][col] {
            case .playedCorrectly:
              if x  != ChaMan.ChallengeStatus.playedCorrectly {
                print("*** cellstate is wrong for \(row), \(col) playedCorrectly says \(x)")
                return false
              }
            case .playedIncorrectly:
              if x  != ChaMan.ChallengeStatus.playedIncorrectly{
                print("*** cellstate is wrong for \(row), \(col) playedIncorrectly says \(x)")
                return false
              }
            case .unplayed:
              if x != ChaMan.ChallengeStatus.allocated {
                print("*** cellstate is wrong for \(row), \(col) unplayed says \(x)")
                return false
              }
            }// switch
            if x == ChaMan.ChallengeStatus.abandoned {
              print("*** cellstate is wrong for \(row), \(col) abandoned says \(x)")
              return false
            }
            if x == ChaMan.ChallengeStatus.inReserve {
              print("*** cellstate is wrong for \(row), \(col) reserved says \(x)")
              return false
            }
          }
        }
      }
    }
    return true
  }
  
  enum CodingKeys: String, CodingKey {
    case _board = "board"
    case _cellstate = "cellstate"
    case _boardsize = "boardsize"
    case _topicsinplay = "topicsinplay"
    case _gamestate = "gamestate"
    case _totaltime = "totaltime"
    case _gamenumber = "gamenumber"
    case _movenumber = "movenumber"
    case _woncount = "woncount"
    case _lostcount = "lostcount"
    case _rightcount = "rightcount"
    case _wrongcount = "wrongcount"
    case _replacedcount = "replacedcount"
    case _faceup = "faceup"
    case _gimmees = "gimmees"
    case _currentscheme = "currentscheme"
    case _veryfirstgame = "veryfirstgame"
    case _startincorners = "startincorners"
    case _doublediag = "doublediag"
    case _difficultylevel = "difficultylevel"
    case _moveindex = "moveindex"
    case _onwinpath = "onwinpath"
    case _replaced = "replaced"
  }
  func basicTopics()->[BasicTopic] {
    return topicsinplay.map {BasicTopic(name: $0)}
  }
  init(size: Int, topics: [String], challenges: [Challenge]) {
    self.topicsinplay = topics //*****4
    self.boardsize = size
    self.board = Array(repeating: Array(repeating: -1, count: size), count: size)
    self.cellstate = Array(repeating: Array(repeating: .unplayed, count: size), count: size)
    self.moveindex = Array(repeating: Array(repeating: -1, count: size), count: size) 
    self.onwinpath = Array(repeating: Array(repeating: false, count: size), count: size)
    self.replaced = Array(repeating: Array(repeating: [], count: size), count: size)
    self.gimmees = 0
    self.gamenumber = 0
    self.movenumber = 0
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
  
  func setupForNewGame (boardsize:Int, chmgr:ChaMan) -> Bool {
    // assume all cleaned up, using size
    var allocatedChallengeIndices:[Int] = []
    self.gamenumber += 1
    self.movenumber = 0
    self.lastmove = nil
    self.boardsize = boardsize ///////////////
    self.board = Array(repeating: Array(repeating: -1, count:  boardsize), count:   boardsize)
    self.moveindex = Array(repeating: Array(repeating: -1, count:  boardsize), count:   boardsize) 
    self.onwinpath = Array(repeating: Array(repeating:false, count:  boardsize), count:   boardsize)
    self.cellstate = Array(repeating: Array(repeating:.unplayed, count: boardsize), count:  boardsize) 
    self.replaced  = Array(repeating: Array(repeating:[], count: boardsize), count:  boardsize)
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
        board[row][col] = idxs
        cellstate[row][col] = .unplayed
        board[row][col] = idxs
      }
    }
    gamestate = .playingNow
    saveGameState() 
    return true
  }
  
  
  func teardownAfterGame (state:StateOfPlay,chmgr:ChaMan) {
    var challenge_indexes:[Int] = []
    gamestate = state
    // examine each board cell and recycle everything thats unplayed
    for row in 0..<boardsize {
      for col in 0..<boardsize {
        if cellstate[row][col] == .unplayed {
          let idx = board[row][col]
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
    // clear out last move
    lastmove = nil
    saveGameState()
  }
  
  // this returns unplayed challenges and their indices in the challengestatus array
  func resetBoardReturningUnplayed() ->   [Int] {
    var unplayedInts: [Int] = []
    for row in 0..<boardsize {
      for col in 0..<boardsize {
        if cellstate[row][col]  == .unplayed {
          unplayedInts.append( (row * boardsize + col))
        }
      }
    }
    return unplayedInts
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
    case 3: return 3
    case 4: return 3
    case 5: return 3
    case 6: return 3
    case 7: return 3
    case 8: return 3
    default: return 3    }
  }
  
  static  func maxTopicsForBoardSize(_ size:Int) -> Int {
    switch size  {
    case 3: return 10
    case 4: return 10
    case 5: return 10
    case 6: return 10
    case 7: return 10
    case 8: return 10
    default: return 10
    }
  }
  
  static  func preselectedTopicsForBoardSize(_ size:Int) -> Int {
    return minTopicsForBoardSize(size)
//    switch size  {
//    case 3: return 2
//    case 4: return 2
//    case 5: return 2
//    case 6: return 2
//    case 7: return 2
//    case 8: return 2
//    default: return 2
//    }
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
    return CGFloat(14-self.boardsize)*(isIpad ? 2.0:1.0) // sensitive
  }
}
