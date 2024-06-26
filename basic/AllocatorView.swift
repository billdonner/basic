//
//  AllocatorView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
struct AllocatorView: View {
  @Binding var playCount: Int
  @Binding var hideCellContent:Bool
  @EnvironmentObject var appColors: AppColors
  @EnvironmentObject var challengeManager: ChallengeManager
  @EnvironmentObject var gameBoard:GameBoard
  @Environment(\.colorScheme) var colorScheme //system light/dark
  
  @State var succ = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Allocated: \(challengeManager.allocatedChallengesCount())")
        Text("Free: \(challengeManager.freeChallengesCount())")
        Text("Played: \(playCount)")
        Spacer()
        //RESET
        Button(action: {
          let unplayedChallenges = gameBoard.resetBoardReturningUnplayed()
          challengeManager.resetChallengeStatuses(at: unplayedChallenges.map { challengeManager.getAllChallenges().firstIndex(of: $0)! })
          challengeManager.resetAllChallengeStatuses(gameBoard: gameBoard)
          hideCellContent = true
          // clearAllCells()
        }) {
          Text("Full Reset")
            .padding()
            .background(Color.black.opacity(0.6))
            .foregroundColor(.red)
            .cornerRadius(8)
        }
        .disabled(!hideCellContent)
        .opacity(hideCellContent ? 1 : 0.5)
      }
      .font(.footnote)
      .padding(.bottom, 8)
      
      if let playData = challengeManager.playData {
        ScrollView {
          VStack(spacing: 4) {
            ForEach(playData.topicData.topics, id: \.name) { topic in
              if challengeManager.allocatedChallengesCount(for: topic) > 0 {
                TopicCountsView(topic: topic)
              }
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
    AllocatorView(playCount:.constant(3), hideCellContent: .constant(false))
      .environmentObject(ChallengeManager())
      .environmentObject(AppColors())
  }
}

struct TopicCountsView: View {
  let topic: Topic
  @EnvironmentObject var appColors: AppColors
  @EnvironmentObject var challengeManager: ChallengeManager
  
  var body: some View {
    HStack {
      RoundedRectangle(cornerSize: CGSize(width: 5.0, height: 5.0))
        .frame(width: 24, height: 24)
        .foregroundColor(appColors.colorFor(topic: topic.name)?.backgroundColor)
      Text(topic.name)
      Spacer()
      Text("\(challengeManager.allocatedChallengesCount(for: topic)) - "
           + "\(challengeManager.freeChallengesCount(for: topic)) - "
           + "\(challengeManager.abandonedChallengesCount(for: topic))")
    }
    .font(.caption)
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
  }
}
