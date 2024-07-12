//
//  ScoreBarView.swift
//  qdemo
//
//  Created by bill donner on 5/24/24.
//

import SwiftUI
private struct zz:View {
  let showchars:String
  @EnvironmentObject var gb: GameBoard
  @EnvironmentObject var challengeManager: ChallengeManager
  @AppStorage("boardSize") var boardSize = 6
  var body: some View{
    VStack {
      HStack {
        Text(showchars).font(showchars.count<=1 ? .title:.footnote)
        Text("games:");Text("\(gb.playcount)")
        Text("won:");Text("\(gb.woncount)")
        Text("lost:");Text("\(gb.lostcount)")
      }
      HStack {
        Text("right:");Text("\(gb.rightcount)")
        Text("wrong:");Text("\(gb.wrongcount)")
        Text("time:");Text(formatTimeInterval(gb.totaltime))
      }
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
        let showchars = if isWinningPath(in:gb.cellstate ) {"😎"}
        else {
          if !isPossibleWinningPath(in:gb.cellstate) {
            "❌"
          } else {
            "moves: \(numberOfPossibleMoves(in: gb.cellstate))"
          }
        }
        zz(showchars: showchars)
      }
      
        if gb.gamestate == .playingNow {
          Text ("game in progress...").foregroundStyle(.blue.opacity(0.5))
        } else {
          Text ("you can start a new game now ").foregroundStyle(.green.opacity(0.5))
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
