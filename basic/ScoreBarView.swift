//
//  ScoreBarView.swift
//  qdemo
//
//  Created by bill donner on 5/24/24.
//

import SwiftUI
struct zz:View {
  let showchar:String
  @EnvironmentObject var gb: GameBoard
  @EnvironmentObject var challengeManager: ChallengeManager
  @AppStorage("boardSize") var boardSize = 6
  var body: some View{
    Text(showchar).font(.largeTitle)
    Text("score:");Text("33")
    Text("gimmees:");Text("\(gb.gimmees)")
    Text("togo:");Text("27")
  }
}
struct ScoreBarView: View {
  @EnvironmentObject var gb: GameBoard
  @State var showWinAlert = false
  @State var showLoseAlert = false
  
  var body:some View {
    return  VStack{
      HStack {
        let showchar = if isWinningPath(in:gb.cellstate ) {"😎"}
        else {
          if !isPossibleWinningPath(in:gb.cellstate) {
            "❌"
          } else {
            " "
          }
        }
        zz(showchar: showchar)
      }
      
        if gb.gamestate == .playingNow {
          Text ("you are currently playing the game!")
        } else {
          Text ("you can start a new game")
        }
      }

      .onChange(of:gb.cellstate) {
        if isWinningPath(in:gb.cellstate) {
          print("--->you have won this game as detected by ScoreBarView")
          showWinAlert = true
        } else {
          if !isPossibleWinningPath(in:gb.cellstate) {
            print("--->you cant possibly win this game s detected by ScoreBarView")
            showLoseAlert = true
          }
        }
      }
    }
  }

#Preview {
  ScoreBarView()
}
