//
//  GameScreenExt.swift
//  basic
//
//  Created by bill donner on 8/4/24.
//

import Foundation

extension GameScreen /* actions */ { 
  func onAppearAction () {
    // on a completely cold start
    if gs.gamenumber == 0 {
      print("//GameScreen OnAppear Coldstart size:\(gs.boardsize) topics: \(topics)")
    } else {
      print("//GameScreen OnAppear Warmstart size:\(gs.boardsize) topics: \(topics)")
    }
    chmgr.checkAllTopicConsistency("gamescreen on appear")
  }
  func onCantStartNewGameAction() {
    print("//GameScreen onCantStartNewGameAction")
    showCantStartAlert = false
  }
  func onYouWin () {
    endGame(status: .justWon)
  }
  func onYouLose () {
    endGame(status: .justLost)
  }
  func onEndGamePressed () {
   // print("//GameScreen EndGamePressed")
    endGame(status:.justAbandoned)
  }
  func onBoardSizeChange() {
    
  }
  func onChangeOfCellState() {
    let (path,iswinner) = winningPath(in:gs.cellstate)
    if iswinner {
      print("--->YOU WIN path is \(path)")
      for p in path {
        gs.onwinpath[p.0][p.1] = true
      }
      showWinAlert = true
    } else {
      if !isPossibleWinningPath(in:gs.cellstate) {
        print("--->YOU LOSE")
        showLoseAlert = true
      }
    }
  }
  func onDump() {
    chmgr.dumpTopics()
  }
  func onStartGame(boardsize:Int ) -> Bool {
   // print("//GameScreen onStartGame before  topics: \(gs.topicsinplay) size:\( boardsize)")
    // chmgr.dumpTopics()
    let ok = gs.setupForNewGame(boardsize:boardsize,chmgr: chmgr )
   // print("//GameScreen onStartGame after")
    // chmgr.dumpTopics()
    if !ok {
      print("Failed to allocate \(gs.boardsize*gs.boardsize) challenges for topic \(topics.joined(separator: ","))")
      print("Consider changing the topics in setting and trying again ...")
    } else {
      firstMove = true
    }
    chmgr.checkAllTopicConsistency("on start game")
    return ok
  }
  func endGame(status:StateOfPlay){
    chmgr.checkAllTopicConsistency("end game")
    gs.teardownAfterGame(state: status, chmgr: chmgr)
  }
}
