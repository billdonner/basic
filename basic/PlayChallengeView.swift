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
  let ch: Challenge
  @Binding var playCount: Int
  @EnvironmentObject var challengeManager: ChallengeManager
  @EnvironmentObject var appColors: AppColors
  @Environment(\.dismiss) var dismiss
  var body: some View {
    let status = (try? challengeManager.getStatus(for:ch).describe()) ?? "err"
    VStack (spacing:20){
      Text(ch.id)
      Text(status)
        RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
          .frame(width: 50,height:24)
          .padding()
          .foregroundColor(appColors.colorFor(topic: ch.topic)?.backgroundColor)
        Text(ch.topic)
      }
      Text(ch.question)
      Button(action: {
        try? challengeManager.setStatus(for: ch, status: ChallengeStatusVal.playedCorrectly)//setStatus(for:ch, status: .playedCorrectly)
        playCount += 1
        dismiss()
      }) {
        
        Text("Mark Correct")
      }
      Button(action: {
        try! challengeManager.setStatus(for:ch, status: .playedIncorrectly)
        playCount += 1
        dismiss()
      }) {
        Text("Mark InCorrect")
      }
      Button(action: {
        playCount += 1
        dismiss()
      }) {
       // challengeManager.replaceChallengeAnyTopic (for:ch)
        Text("Gimmee Only")
      }
    
    Button(action: {
      playCount += 1
      dismiss()
    }) {
      //challengeManager.replaceChallengeWithinTopic (for:ch)
      Text("Gimmee Any")
    }
      Button(action: {
        dismiss()
      }) {
        Text("Pass/Ignore")
      }
    }
  }
#Preview{
  @Previewable @State var playCount = 0
  PlayChallengeView(ch:Challenge.mock, playCount: $playCount).environmentObject(AppColors())
  
}
