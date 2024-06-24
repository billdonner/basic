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
  @EnvironmentObject var challengeManager: ChallengeManager
  @EnvironmentObject var appColors: AppColors
  @Environment(\.dismiss) var dismiss
  var body: some View {
    VStack (spacing:20){
      Text(ch.id)
      HStack{
        RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
          .frame(width: 50,height:24)
          .padding()
          .foregroundColor(appColors.colorFor(topic: ch.topic)?.backgroundColor)
        Text(ch.topic)
      }
      Text(ch.question)
      Button(action: {
        try! challengeManager.setStatus(for:ch, status: .playedCorrectly)
        dismiss()
      }) {
        
        Text("Mark Correct")
      }
      Button(action: {
        try! challengeManager.setStatus(for:ch, status: .playedIncorrectly)
        dismiss()
      }) {
        Text("Mark InCorrect")
      }
      Button(action: {
        dismiss()
      }) {
       // challengeManager.replaceChallengeAnyTopic (for:ch)
        Text("Gimmee Only")
      }
    
    Button(action: {
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
}
#Preview{
  PlayChallengeView(ch:Challenge.mock).environmentObject(AppColors())
  
}
