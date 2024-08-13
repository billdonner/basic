//
//  GameLogScreen.swift
//  basic
//
//  Created by bill donner on 8/13/24.
//

import SwiftUI

struct GameLogScreen: View {
  internal init( gs: GameState,chmgr:ChaMan) {
    self.movehistory = gs.moveHistory()
    self.gs = gs
    self.chmgr = chmgr
  }
  
  @State var movehistory: [GameMove] = []
  let gs:GameState
  let chmgr:ChaMan
  var body: some View {
    
      Text("Game #\(gs.gamenumber)").font(.title)
      Text("\(gs.gamestart)").font(.footnote)
      Text("\(gs.totaltime) secs").font(.footnote)
      Text("\(joinWithCommasAnd(gs.topicsinplay))").font(.footnote)
      List {
        ForEach(movehistory, id:\.self ) { move in
          let row = move.row
          let col = move.col
          let ch = chmgr.everyChallenge[gs.board[row][col]]
          let ansinfo = chmgr.ansinfo[ch.id]
          let sym = switch gs.cellstate[row][col] {
          case .playedCorrectly:
           "✅"
          case .playedIncorrectly:
            "❌"
          case .unplayed:
            ""
          }
          Text("\(move.movenumber) : @(\(row),\(col))\(ch.topic)")
          Text("\(ch.question)")
          Text("correct answer: \(ch.correct)")
          HStack {
            Text("your answer: \(ansinfo?.answer ?? "none" )")
            Spacer()
            Text("\(sym)").font(.caption)
          }
        }
      }
      
    }
}

#Preview {
  GameLogScreen(gs:GameState.mock, chmgr:ChaMan.mock)
}
