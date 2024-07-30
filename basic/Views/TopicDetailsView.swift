//
//  TopicDetailsView.swift
//  basic
//
//  Created by bill donner on 7/30/24.
//

import SwiftUI

struct TopicDetailsView: View {
  let topic:String
  let gs:GameState
  let chmgr:ChaMan
  
    var body: some View {
      let x = gs.indexOfTopic(topic)
      let y = "\(chmgr.allocatedChallengesCount(for: topic )) - "
           + "\(chmgr.freeChallengesCount(for: topic )) - "
           + "\(chmgr.abandonedChallengesCount(for: topic )) - "
           + "\(chmgr.correctChallengesCount(for: topic )) - "
           + "\(chmgr.incorrectChallengesCount(for: topic ))"
      let tinfo = chmgr.tinfo[topic]
      if let tinfo = tinfo {
        let (chas,stas) = tinfo.getChallengesAndStatuses(chmgr: chmgr)
        Text("\(x ?? -1 )   \(y)")
        ForEach(0..<chas.count,id:\.self) { idx in
          Text("idx: \(idx) -\(chas[idx].question) - \(stas[idx]) ")
        }
        
        
        
        
      } else {
        Color.red
      }
    }
}

#Preview {
  TopicDetailsView(topic:"Fun",gs:GameState(size: 3, topics:Array(MockTopics.mockTopics.prefix(7)), challenges: Challenge.mockChallenges), chmgr: ChaMan(playData: PlayData.mock))
}
