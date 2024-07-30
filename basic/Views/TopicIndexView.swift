//
//  AllocatorView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
struct TopicIndexView: View {
    let gs: GameState
    @Environment(\.colorScheme) var colorScheme // System light/dark
    @State var succ = false

    private let columns = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]
    
    var body: some View {
        VStack {
         
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(gs.basicTopics(), id: \.name) { topic in
                        HStack {
                            RoundedRectangle(cornerSize: CGSize(width: 10.0, height: 3.0))
                                .frame(width: 15, height: 15)
                                .foregroundStyle(colorForTopic(topic.name, gs: gs).0)
                          Text(truncatedText(topic.name, count: isIpad ? 40 : 10))
                                .font(.caption2) // Smaller font
                                .foregroundColor(textColor)
                        }
                        .padding(.vertical, 0)
                        .padding(.horizontal, 4)
                        .background(Color(white: 0.9))
                        .cornerRadius(8)
                    }
                }
                .padding(4)
              
                .background(Color.black.opacity(0.1)) // Dark gray outer background
              
              .cornerRadius(10)
            }
      
        .padding()
    }
    
    // Computed properties for background and text colors
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.96)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    // Function to truncate text to 30 characters
    private func truncatedText(_ text: String,count: Int ) -> String {
        if text.count > count {
            let index = text.index(text.startIndex, offsetBy: count)
            return String(text[..<index]) + "..."
        } else {
            return text
        }
    }
}
// Assuming you have the ChaMan and colorSchemes to preview the view
struct TopicIndexView_Previews: PreviewProvider {
  static var previews: some View {
    TopicIndexView(
                  gs: GameState(size: 3, topics:Array(MockTopics.mockTopics.prefix(12)), challenges: Challenge.mockChallenges))
  }
}
