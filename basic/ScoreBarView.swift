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
  @Binding var hideCellContent: Bool
  @EnvironmentObject var gb: GameBoard
  @State var showAlert = false
  @State var winlose = false
  
  var body:some View {
    return  VStack{
      HStack {
        let showchar = if isWinningPath(in:gb.cellstate ) {"😎"}
        else {
          if isPossibleWinningPath(in:gb.cellstate) {
            "☡"
          } else {
            "❌"
          }
        }
        zz(showchar: showchar)
          .alert(winlose ? " You Win " : " You Lose ",
                 isPresented: $showAlert){
            Button("OK", role: .cancel) {
                          hideCellContent = true
           
            }

          }.font(.headline).padding()
      }
      
      
      
      .onChange(of:gb.cellstate) {
        if isWinningPath(in:gb.cellstate) {
          print("--->you have already won but can play on")
          winlose = true
          showAlert = true
        } else {
          if !isPossibleWinningPath(in:gb.cellstate) {
            winlose = false
            showAlert = true
            print("--->you cant possibly win")
          }
        }
      }
    }
  }
}
#Preview {
  ScoreBarView(hideCellContent: .constant(true))
}
