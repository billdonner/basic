//
//  SettingsFormScreen.swift
//  qdemo
//
//  Created by bill donner on 4/23/24.
//

import SwiftUI
struct DismissButtonView: View {
  @Environment(\.dismiss) var dismiss
  var body: some View {
    VStack {
      // add a dismissal button
      HStack {
        Spacer()
        Button {
          dismiss()
        } label: {
          Image(systemName: "x.circle").padding(EdgeInsets(top:10, leading: 0, bottom: 40, trailing: 20))
        }
      }
      Spacer()
    }
  }
}

struct FreeportSettingsScreen: View {
  var gameBoard: GameBoard
  var chmgr: ChaMan
  
  @AppStorage("elementWidth") var elementWidth = 100.0
  @AppStorage("shuffleUp") private var shuffleUp = true
  @AppStorage("fontsize") private var fontsize = 24.0
  @AppStorage("padding") private var padding = 2.0
  @AppStorage("border") private var border = 3.0
  @State var selectedLevel:Int = 1
  @State var showOnBoarding = false
  @State var showReset = false
  @State private var isSelectedArray = [Bool](repeating: false, count: 26)
  var body: some View {
    ZStack {
      DismissButtonView()
      VStack {
        Text("Freeport Controls")
        Form {
          Section(header: Text("Not For Civilians")) {
            VStack(alignment: .leading) {
              Text("SIZE Current: \( elementWidth, specifier: "%.0f")")
              Slider(value:  $elementWidth, in: 60...300, step: 1.0)
            }
            VStack(alignment: .leading) {
              Text("FONTSIZE Current: \( fontsize, specifier: "%.0f")")
              Slider(value:  $fontsize, in: 8...40, step: 2.0)
            }
            VStack(alignment: .leading) {
              Text("PADDING Current: \( padding, specifier: "%.0f")")
              Slider(value:  $padding, in: 1...40, step: 1.0)
            }
            VStack(alignment: .leading) {
              Text("BORDER Current: \( border, specifier: "%.0f")")
              Slider(value:  $border, in: 0...20, step: 1.0)
            }
            
            Button(action:{ showOnBoarding.toggle() }) {
              Text("Replay OnBoarding")
            }.padding(.vertical)
            
            Button(action:{ //showReset.toggle()
                    let _ = gameBoard.resetBoardReturningUnplayed()
                     chmgr.totalresetofAllChallengeStatuses(gameBoard: gameBoard)
              
            }) {
              Text("Factory Reset")
            }.padding(.vertical)

          }
        }
        .fullScreenCover(isPresented: $showOnBoarding) {
          OnboardingScreen(isPresented: $showOnBoarding)
        }
        
        Spacer()
        // Text("It is sometimes helpful to rotate your device!!").font(.footnote).padding()
      }
    }
  }
}

#Preview ("Settings"){
  FreeportSettingsScreen(gameBoard: 
                          GameBoard(size: starting_size,topics: Array(MockTopics.mockTopics.prefix(starting_size)),
                                                challenges:Challenge.mockChallenges)  
                          , chmgr: ChaMan(playData: PlayData.mock))
}

