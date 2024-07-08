//
//  ScoreBarView.swift
//  qdemo
//
//  Created by bill donner on 5/24/24.
//

import SwiftUI
struct zz:View {
  let showchar:String
  @AppStorage("boardSize") var boardSize = 6
  var body: some View{
    Text(showchar).font(.largeTitle)
//    Text("score:");Text("\(gameState.grandScore)").font(.largeTitle)
//    Text("gimmees:");Text("\(gameState.gimmees)").font(.largeTitle)
//    Text("togo:");Text("\(boardSize*boardSize - gameState.grandScore - gameState.grandLosers)").font(.largeTitle)
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
          if isPossibleWinningPath(in:gb.cellstate) {
            " "
          } else {
            "❌"
          }
        }
        zz(showchar: showchar)
      }
    }
  }
}

#Preview {
  ScoreBarView()
}
