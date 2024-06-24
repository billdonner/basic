//
//  PlayChallengeView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI

extension Challenge {
  static   let mock = Challenge(question: "For Madmen Only", topic: "Animals", hint: "long time ago", answers: ["most","any","old","song"], correct: "old", id: "UUID320239", date: Date.now, aisource: "donner's brain")
}

struct PlayChallengeView:View {
  let row : Int
  let col : Int
  @Binding var playCount: Int
  //@EnvironmentObject var challengeManager: ChallengeManager
  @EnvironmentObject var appColors: AppColors
  @EnvironmentObject var gb: GameBoard
  @Environment(\.dismiss) var dismiss
  var body: some View {
   // let status = (try? challengeManager.getStatus(for:ch).describe()) ?? "err"
    let ch = gb.board[row][col]
    VStack (spacing:20){
      Text(ch.id)
      //Text(status)
        RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
          .frame(width: 50,height:24)
          .padding()
          .foregroundColor(appColors.colorFor(topic: ch.topic)?.backgroundColor)
        Text(ch.topic)
      }
      Text(ch.question)
      Button(action: {
        gb.cellstate[row][col] = .playedCorrectly
        playCount += 1
        dismiss()
      }) {   Text("Mark Correct") }
      Button(action: {
        gb.cellstate[row][col] = .playedIncorrectly
        playCount += 1
        dismiss()
      }) {  Text("Mark InCorrect")  }
    
      Button(action: {
        playCount += 1
        dismiss()
      }) {  Text("Gimmee Only")  }
    
    Button(action: {
      playCount += 1
      dismiss()
    }) {  Text("Gimmee Any")  }
    Button(action: {
        dismiss()
      }) {
        Text("Pass/Ignore")
      }
    }
  }
#Preview{
  @Previewable @State var playCount = 0
  PlayChallengeView(row:0,col:0,playCount: $playCount)
    .environmentObject(AppColors())
    .environmentObject(GameBoard(size: 1, topics:["Fun"], challenges: [Challenge.mock]))
  
}
