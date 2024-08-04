//
//  TopicDetailsView.swift
//  basic
//
//  Created by bill donner on 7/30/24.
//

import SwiftUI
func isUsedup(_ status:ChaMan.ChallengeStatus) -> Bool {
  switch status {
  case .abandoned:
    return true
    case .playedCorrectly:
      return true
  case .playedIncorrectly:
    return true
  default:
    return false
  }
}
struct TopicDetailsView: View {
  let topic:String
  let gs:GameState
  let chmgr:ChaMan
  
    var body: some View {
      let y =
           "\(chmgr.freeChallengesCount(for: topic ))"
      let colors = gs.colorForTopic(topic)
      let tinfo = chmgr.tinfo[topic]
      if let tinfo = tinfo {
        let (chas,stas) = tinfo.getChallengesAndStatuses(chmgr: chmgr)
        VStack {
        Text("\(topic)")
         Text("\(chas.count) challenges, of which \(y) unplayed").font(.footnote)
        
          List {
            ForEach(0..<chas.count,id:\.self) { idx in
              if isUsedup(stas[idx]) {
                Text("\(truncatedText(chas[idx].question,count:200))")
                Text(" \(stas[idx]) ").font(.footnote)
              }
            }
          }
        }.background(colors.0)
          .foregroundColor(colors.1)
      } else {
        Color.red
      }
    }
}

#Preview {
  TopicDetailsView(topic:"Fun",gs:GameState(size: 3, topics:Array(MockTopics.mockTopics.prefix(7)), challenges: Challenge.mockChallenges), chmgr: ChaMan(playData: PlayData.mock))
}
