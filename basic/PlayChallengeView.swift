//
//  PlayChallengeView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI

extension Challenge {
  static   let mock = Challenge(question: "For Madmen Only", topic: "Flowers", hint: "long time ago", answers: ["most","any","old","song"], correct: "old", id: "UUID320239", date: Date.now, aisource: "donner's brain")
}
struct PlayChallengeView:View {
  let ch: Challenge
  @EnvironmentObject var appColors: AppColors
  @Environment(\.dismiss) var dismiss
  var body: some View {
    VStack {
      HStack{
        RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
          .frame(width: 50,height:24)
          .padding()
          .foregroundColor(AppColors.colorFor(topic: ch.topic)?.backgroundColor)
        Text(ch.topic)
      }
      Text(ch.question)
      Button(action: {
        dismiss()
      }) {
        Text("Mark Correct")
      }
      Button(action: {
        dismiss()
      }) {
        Text("Mark InCorrect")
      }
      Button(action: {
        dismiss()
      }) {
        Text("Gimmee")
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
