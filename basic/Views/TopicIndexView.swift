//
//  AllocatorView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
struct TopicIndexView: View {
  let  gs:GameState
  @Environment(\.colorScheme) var colorScheme //system light/dark
  @State var succ = false
  
  var body: some View {
    VStack {
      ScrollView {
        VStack(spacing: 4) {
          ForEach(gs.basicTopics(), id: \.name) { topic in
            HStack {
              RoundedRectangle(cornerSize: CGSize(width: 15.0, height: 5.0))
                .frame(width: 24, height: 24)
                .foregroundStyle(colorForTopic(topic ,gs:gs).0)
              Text(topic )
            }
            .font(.caption)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            }
          }
      }
    }
    .background(backgroundColor)
    .padding()
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
struct TopicIndexView_Previews: PreviewProvider {
  static var previews: some View {
    TopicIndexView(
                  gs: GameState(size: 3, topics:Array(MockTopics.mockTopics.prefix(7)), challenges: Challenge.mockChallenges))
  }
}
