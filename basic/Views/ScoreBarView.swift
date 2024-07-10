//
//  ScoreBarView.swift
//  qdemo
//
//  Created by bill donner on 5/24/24.
//

import SwiftUI
private struct zz:View {
  let showchar:String
  @EnvironmentObject var gb: GameBoard
  @EnvironmentObject var challengeManager: ChallengeManager
  @AppStorage("boardSize") var boardSize = 6
  var body: some View{
    Text(showchar).font(.largeTitle)
    HStack {
      Text("games:");Text("\(gb.playcount)")
      Text("won:");Text("\(gb.woncount)")
      Text("lost:");Text("\(gb.lostcount)")
      Text("right:");Text("\(gb.rightcount)")
      Text("wrong:");Text("\(gb.wrongcount)")
    }.font(.footnote)
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
          Text ("game in progress...")
        } else {
          Text ("you can start a new game")
        }
      }

      .onChange(of:gb.cellstate) {
        if isWinningPath(in:gb.cellstate) {
          print("--->you have won this game as detected by ScoreBarView")
          showWinAlert = true
          gb.woncount += 1
          gb.saveGameBoard()
          
        } else {
          if !isPossibleWinningPath(in:gb.cellstate) {
            print("--->you cant possibly win this game s detected by ScoreBarView")
            showLoseAlert = true
            gb.lostcount += 1
            gb.saveGameBoard()
          }
        }
      }
    }
  }

#Preview {
  ScoreBarView().environmentObject(GameBoard(size: 3, topics: ["a","b","c"], challenges: []))
}
