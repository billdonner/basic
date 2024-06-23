//
//  AllocatorView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI

struct AllocatorView: View {
    @EnvironmentObject var appColors: AppColors
    @EnvironmentObject var challengeManager: ChallengeManager
    @Environment(\.colorScheme) var colorScheme //system light/dark
    
  @State var succ = false

    var body: some View {
        Group {
            if let playData = challengeManager.playData {
                ScrollView {
                  ForEach(playData.topicData.topics, id: \.name) { topic in
                        if challengeManager.allocatedChallengesCount(for: topic) > 0 {
                          TopicCountsView(topic:topic)
                        }
                    }
                }
            } else {
                Text("Loading...")
                    .foregroundColor(textColor)
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

// Assuming you have the challengeManager and colorSchemes to preview the view
struct AllocatorView_Previews: PreviewProvider {
    static var previews: some View {
        AllocatorView()
            .environmentObject(ChallengeManager())
            .environmentObject(AppColors())
    }
}
