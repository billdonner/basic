//
//  QandAScreenExt.swift
//  basic
//
//  Created by bill donner on 8/3/24.
//

import SwiftUI
extension QandAScreen {
  
func handleDismissal(toRoot:Bool) {
    if toRoot {
      withAnimation(.easeInOut(duration: 0.75)) { // Slower dismissal
        isPresentingDetailView = false
        dismiss()
      }
    } else {
      answerGiven = false //showAnsweredAlert = false
      showHint=false //  showHintAlert = false
    }
  }
  
  func toggleHint() {
    if chmgr.everyChallenge[gs.board[row][col]]
      .hint.count > 1  { // guard against short hints
      showHint.toggle()
    }
  }
  
  func handleGimmee(row:Int,col:Int) {
    let idx = row*gs.boardsize + col
    let result = chmgr.replaceChallenge(at:idx)
    switch result {
    case .success(let index):
      gs.gimmees -= 1
      gs.board[row][col] = index[0]
      print("Gimmee realloation successful")
      
    case .error(let error):
      print("Couldn't handle gimmee reallocation \(error)")
    }
    killTimer = true
    dismiss()
  }
  
  func handlePass() {
    killTimer=true
    dismiss()
  }
  
  func answeredCorrectly(_ ch:Challenge,row:Int,col:Int,answered:String) {
    chmgr.checkAllTopicConsistency("mark correct before")
    assert(gs.checkVsChaMan(chmgr: chmgr))
    answerCorrect = true
    answerGiven = true
    showBorders = true
    gs.movenumber += 1
    gs.moveindex[row][col] = gs.movenumber
    gs.cellstate[row][col] = .playedCorrectly
    gs.rightcount += 1
    chmgr.bumpRightcount(topic: ch.topic)
    chmgr.stati[gs.board[row][col]] = .playedCorrectly  // ****
    chmgr.ansinfo[ch.id]  =
    AnsweredInfo(id: ch.id, answer: answered, outcome:.playedCorrectly,
                 timestamp: Date(), timetoanswer:elapsedTime, gamenumber: gs.gamenumber, movenumber: gs.movenumber,row:row,col:col)
    killTimer=true
    gs.saveGameState()
    chmgr.save()
    chmgr.checkAllTopicConsistency("mark correct after")
  }
  func answeredIncorrectly(_ ch:Challenge,row:Int,col:Int,answered:String) {
    chmgr.checkAllTopicConsistency("mark incorrect before")
    assert(gs.checkVsChaMan(chmgr: chmgr))
    answerCorrect = false
    answerGiven = true
    showCorrectAnswer = false
    showBorders = true
    gs.movenumber += 1
    gs.moveindex[row][col] = gs.movenumber
    gs.cellstate[row][col] = .playedIncorrectly
    gs.wrongcount += 1
    chmgr.bumpWrongcount(topic: ch.topic)
    chmgr.stati[gs.board[row][col]] = .playedIncorrectly  // ****
    chmgr.ansinfo[ch.id]  =
    AnsweredInfo(id: ch.id, answer: answered, outcome:.playedIncorrectly,
                 timestamp: Date(), timetoanswer: elapsedTime, gamenumber: gs.gamenumber, movenumber: gs.movenumber,row:row,col:col)

    killTimer=true
    chmgr.save()
    gs.saveGameState()
    chmgr.checkAllTopicConsistency("mark incorrect after")
  }
  func handleAnswerSelection(answer: String,row:Int,col:Int) {
    if !questionedWasAnswered { // only allow one answer
      let ch = chmgr.everyChallenge[gs.board[row][col]]
      selectedAnswer = answer
      answerCorrect = (answer == ch.correct)
      answerGiven = true
      
      switch answerCorrect {
      case true: answeredCorrectly(ch,row:row,col:col,answered:answer)
      case false: answeredIncorrectly(ch,row:row,col:col,answered: answer)
      }
      questionedWasAnswered = true
    } else {
      print("dubl tap \(answer)")
    }
  }
}
