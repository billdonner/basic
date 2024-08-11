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
  @State private var showApview:Challenge?  = nil
  var body: some View {
//      let unplayedCount = "\(chmgr.freeChallengesCount(for: topic))"
      let colors = gs.colorForTopic(topic)
      let tinfo = chmgr.tinfo[topic]
      
      if let tinfo = tinfo {
          let (chas, stas) = tinfo.getChallengesAndStatuses(chmgr: chmgr)
          
          VStack {
              ZStack {
                  colors.0
                      .ignoresSafeArea(edges: .top)
                  VStack {
                      Text(topic)
                          .font(.largeTitle)
                          .fontWeight(.bold)
                          .shadow(color: .black, radius: 1, x: 0, y: 1)
                          .padding(.top, 50)
                      Text("\(chas.count) challenges in this topic")
                          .font(.footnote)
                          .shadow(color: .black, radius: 1, x: 0, y: 1)
                  }
                  .foregroundColor(colors.1)
                  .padding()
              }
              List {
                  ForEach(0..<chas.count, id: \.self) { idx in
                      if isUsedup(stas[idx]) {
                          HStack {
                              VStack(alignment: .leading) {
                                  Text(truncatedText(chas[idx].question, count: 200))
                                  Text(" \(stas[idx]) ")
                                      .font(.footnote)
                              }
                              Spacer()
                              Image(systemName: "chevron.right")
                                  .foregroundColor(.gray)
                          }
                          .contentShape(Rectangle()) // Make the entire HStack tappable
                          .onTapGesture {
                              showApview = chas[idx]
                          }
                      }
                  }
              }
              .sheet(item: $showApview) { challenge in
                  AlreadyPlayedView(ch: challenge, gs: gs, chmgr: chmgr)
              }
          }
      } else {
          Color.red
      }
  }
  
}

#Preview {
  TopicDetailsView(topic:"Fun",gs:GameState.mock,
    chmgr: ChaMan.mock )
}
