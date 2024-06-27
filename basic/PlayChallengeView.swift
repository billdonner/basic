//
//  PlayChallengeView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI

struct PlayChallengeView:View {
  let row : Int
  let col : Int
  
  @Binding var playCount: Int
  @EnvironmentObject var appColors: AppColors
  @EnvironmentObject var gb: GameBoard
  @Environment(\.dismiss) var dismiss
  var body: some View {
    let ch = gb.board[row][col]
    let state = gb.cellstate[row][col]
    VStack (spacing:30){
      //Text(ch.id)
      //Text(status)
      HStack{   RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
          .frame(width: 50,height:24)
          .padding()
          .foregroundColor(appColors.colorFor(topic:ch.topic)?.backgroundColor)
        RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
          .frame(width: 50,height:24)
          .padding()
          .foregroundColor(state.borderColor )
      }
        Text(ch.topic)
  
      Text(ch.question)
      Button(action: {
        gb.cellstate[row][col] = .playedCorrectly
        playCount += 1
        gb.saveGameBoard()
        dismiss()
      }) {   Text("Mark Correct") }
      Button(action: {
        gb.cellstate[row][col] = .playedIncorrectly
        playCount += 1
        gb.saveGameBoard()
        dismiss()
      }) {  Text("Mark InCorrect")  }
    
      Button(action: {
        playCount += 1
        gb.saveGameBoard()
        dismiss()
      }) {  Text("Gimmee Only")  }
    
    Button(action: {
      playCount += 1 
      gb.saveGameBoard()
      dismiss()
    }) {  Text("Gimmee Any")  }
    Button(action: {
        dismiss()
      }) {
        Text("Pass/Ignore")
      }
    }    }
  }
//#Preview{
//  @Previewable @State var playCount = 0
//  PlayChallengeView(row:0,col:0,playCount: $playCount)
//    .environmentObject(AppColors())
//    .environmentObject(GameBoard(size: 1, topics:["Fun"], challenges: [Challenge.mock]))
//  
//}
