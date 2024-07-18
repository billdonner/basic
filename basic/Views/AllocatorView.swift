//
//  AllocatorView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
struct AllocatorView: View {
  let chmgr: ChaMan
  let  gameBoard:GameBoard
  @Environment(\.colorScheme) var colorScheme //system light/dark
  @State var succ = false
  
  var body: some View {
    VStack {
      HStack {
        Text("Allocated: \(chmgr.allocatedChallengesCount())")
        Text("Free: \(chmgr.freeChallengesCount())")
        Text("Played: \(gameBoard.playcount)")
      }
      .font(.footnote)
      .padding(.bottom, 8)
      
      let playData = chmgr.playData
      ScrollView {
        VStack(spacing: 4) {
          ForEach(playData.topicData.topics, id: \.name) { topic in
            if chmgr.allocatedChallengesCount(for: topic.name) > 0 {
              TopicCountsView(topic: topic,chmgr: chmgr, gameBoard: gameBoard )
            }
          }
        }
        Divider()
        VStack(spacing: 4) {
          ForEach(playData.topicData.topics, id: \.name) { topic in
            if chmgr.allocatedChallengesCount(for: topic.name) <=  0 {
              TopicCountsView(topic: topic,chmgr: chmgr,gameBoard: gameBoard)
            }
          }
        }
      }
    }
    .background(backgroundColor)
    .padding()
    .onAppear {
      print("//AllocatorView onAppear size:\(gameBoard.size) topics:\(gameBoard.topicsinplay)")
    }
    .onDisappear {
      print("//AllocatorView onDisappear size:\(gameBoard.size) topics:\(gameBoard.topicsinplay)")
      
    }
  }
  
  // Computed properties for background and text colors
  private var backgroundColor: Color {
    colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.96)
  }
  
  private var textColor: Color {
    colorScheme == .dark ? Color.white : Color.black
  }
}

// Assuming you have the ChaMan and colorSchemes to preview the view
struct AllocatorView_Previews: PreviewProvider {
  static var previews: some View {
    AllocatorView(chmgr: ChaMan(playData:PlayData.mock),
                  gameBoard: GameBoard(size: 3, topics:Array(MockTopics.mockTopics.prefix(7)), challenges: Challenge.mockChallenges))
    
  }
}

fileprivate struct TopicCountsView: View {
  let topic: BasicTopic
  let chmgr: ChaMan
  let gameBoard: GameBoard
  
  var counts: some View {
    Text("\(chmgr.allocatedChallengesCount(for: topic.name)) - "
         + "\(chmgr.freeChallengesCount(for: topic.name)) - "
         + "\(chmgr.abandonedChallengesCount(for: topic.name)) - "
         + "\(chmgr.correctChallengesCount(for: topic.name)) - "
         + "\(chmgr.incorrectChallengesCount(for: topic.name))"
    )
  }
  var body: some View {
    HStack {
      RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
        .frame(width: 24, height: 24)
      Text(topic.name)
      Spacer()
      counts
    }
    .font(.caption)
    .background(colorForTopic(topic.name,gb:gameBoard).0)
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
  }
}
