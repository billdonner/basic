//
//  AlreadyTappedVIew.swift
//  basic
//
//  Created by bill donner on 8/1/24.
//
import SwiftUI

struct AlreadyPlayedView : View {
  let row:Int
  let col:Int
  let gs:GameState
  let chmgr: ChaMan
  @Environment(\.dismiss) var dismiss  // Environment value for dismissing the view
  var body: some View {
    let chidx = gs.board[row][col]
    let ch = chmgr.everyChallenge[chidx]
    
    Text("Already Tapped on \(row),\(col) state is \(gs.cellstate[row][col])")
    
    Text (ch.question)
    Text (ch.correct)
    Text ("\(ch.answers)")
    Text (ch.explanation ?? "no explanation")
  }
}
