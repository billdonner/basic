//
//  ChallengeInfoScreen.swift
//  basic
//
//  Created by bill donner on 7/25/24.
//

import SwiftUI

struct ChallengeInfoScreen: View {
  let challenge:Challenge
  
  @Environment(\.dismiss) var dismiss
  var body: some View {
    
    NavigationStack {
      ScrollView {
        VStack(spacing:20){
          VStack(spacing:5){
            HStack{
              Text("challenge id:")
              Spacer()
              Text(challenge.id )
            }
            HStack{
              Text("source:")
              Spacer()
              Text( challenge.aisource )
            }
            HStack{
              Text("generated:")
              Spacer()
              Text(challenge.date.formatted())
            }
            HStack{
              Text("topic:")
              Spacer()
              Text(challenge.topic)
            }
            Divider()
            HStack{
              Text("question:")
              Spacer()
              Text(challenge.question).font(.headline)
            }
            Divider()
            HStack{
              Text("correct:")
              Spacer()
              Text(challenge.correct).font(.headline)
            }
            Divider()
            HStack{
              Text("possible:")
              Spacer()
              VStack {
                ForEach(challenge.answers,id:\.self) { answer in
                  Text(answer).font(.headline)
                }
              }
             
            }
            Divider()
            HStack{
              Text("hint:")
              Spacer()
              Text(challenge.hint).font(.headline)
            }
            Divider()
            HStack{
              Text("explain:")
              Spacer()
              Text(challenge.explanation ?? "none given").font(.headline)
            }
          }
//          HStack{
//            Text("Veracity Opinions From Other Chatbots").font(.headline)
//            Spacer()
//          }.font(.headline)
 //         VStack(spacing:5){

//          HStack{
//            Text("Prompt sent to ChatBot")
//            Spacer()
//          }.font(.headline)
//          VStack(spacing:5){
//            Text(decodeStringFromJSON(encodedString: challenge.prompt))
//              .borderedStyle(.blue)
//          }
        }
      }
      .navigationBarItems(leading:     Button {
        dismiss()
      } label: {
        Text("Done")
      })
      .navigationTitle("Challenge Details")
      .padding()
    }
  }
}



#Preview {
  ChallengeInfoScreen(challenge:Challenge.complexMock)
}
