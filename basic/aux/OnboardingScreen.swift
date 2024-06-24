//
//  Onboarding.swift
//  qview
//
//  Created by bill donner on 6/9/24.
//

import SwiftUI

/**
### Panel 1: Welcome & Objective
- **Title:** Welcome to QANDA Game!
- **Content:** Provide a brief overview of the game and its main objective.
  - "Welcome to QANDA! In this game, you'll answer trivia questions to connect two diagonal corners on a grid. Answer questions correctly to complete a path from one corner to its opposite corner."
*/
 struct OB01: View {
   @Binding var isPresented:Bool
   var body: some View {
     VStack {
      // WrappedDismissButton(isPresented: $isPresented)
  
         
     MatrixView(
             rows: 6, cols: 6,
             matrix:
              
              PDMatrix(rows: 6, cols: 6, pdms: [
               PDM((row: 0, col: 0), move: Move(.correct, text: ntoSF(1))),
               PDM((row: 1, col: 1), move: Move(.incorrect, text: ntoSF(2))),
               PDM((row: 0, col: 1), move: Move(.correct, text: ntoSF(3))),
               PDM((row: 1, col: 2), move: Move(.correct, text: ntoSF(4))),
               PDM((row: 2, col: 2), move: Move(.correct, text: ntoSF(5))),
               PDM((row: 3, col: 3), move: Move(.correct, text: ntoSF(6))),
               PDM((row: 4, col: 4), move: Move(.incorrect, text: ntoSF(7))),
               PDM((row: 4, col: 3), move: Move(.correct, text: ntoSF(8))),
               PDM((row: 5, col: 4), move: Move(.correct, text: ntoSF(9))),
               PDM((row: 5, col: 5), move: Move(.correct, text: ntoSF(10))),
             ]),
             topLabel:nil,
             bottomLabel: nil,
             correctColor: .green,
             incorrectColor: .red,
             isPresented: $isPresented
           )
         Text("Welcome to QANDA Game!")
           .font(.title)
           .padding()
         Text("Welcome to QANDA! In this game, you'll answer trivia questions to connect two diagonal corners on a grid. Answer questions correctly to complete a path from one corner to its opposite corner.")
           .padding()
       }
     }
}

 /**
### Panel 2: Game Board & Topics
- **Title:** Game Board & Topics
- **Content:** Explain the game board layout and how topics are organized and color-coded.
  - "Each game board is a grid of cells with questions inside. Each cell is color-coded by topic. Choose and answer questions in any order, but you must create a continuous path of correct answers from corner to corner!"
  */

struct OB02: View {
  @Binding var isPresented:Bool
  var body: some View {
    ZStack {
      WrappedDismissButton(isPresented: $isPresented)
      VStack {
        Image("Onboarding2")
          .resizable()
          .scaledToFit()
          .padding()
        Text("Game Board & Topics")
          .font(.title)
          .padding()
        Text("Each game board is a grid of cells with questions inside. Each cell is color-coded by topic. Choose and answer questions in any order, but you must create a continuous path of correct answers from corner to corner!")
          .padding()
      }
    }
  }
}


/*
  ### Panel 3: Selecting Topics
- **Title:** Selecting Topics
- **Content:** Explain the topic screen how topics are organized and color-coded.
  - "You can choose some topics, but we will choose the others. If you dont like our choices, you can re-roll them once!  We'll pick the colors or you can choose your own"
 */

struct OB03: View {
  @Binding var isPresented:Bool
  var body: some View {
    ZStack {
      WrappedDismissButton(isPresented: $isPresented)
      VStack {
        Image("Onboarding3")
          .resizable()
          .scaledToFit()
          .padding()
        Text("Selecting Topics")
          .font(.title)
          .padding()
        Text("You can choose some topics, but we will choose the others. If you dont like our choices, you can re-roll them once!  We'll pick the colors or you can choose your own")
          .padding()
      }
    }
  }
}

/*

### Panel 4: Answering Questions
- **Title:** Answering Questions
- **Content:** Describe the multiple-choice questions and how to interact with them.
  - "Tap any cell to see a multiple-choice question. Answer correctly to earn a point and mark the cell as correct. Incorrect answers mark the cell as incorrect. You can only move to adjacent cells next."
*/

struct OB04: View {
  @Binding var isPresented:Bool
  var body: some View {
    ZStack {
      WrappedDismissButton(isPresented: $isPresented)
      VStack {
        Image("Onboarding4")
          .resizable()
          .scaledToFit()
          .padding()
        Text("Answering Questions")
          .font(.title)
          .padding()
        Text("Tap any cell to see a multiple-choice question. Answer correctly to earn a point and mark the cell as correct. Incorrect answers mark the cell as incorrect. You can only move to adjacent cells next.")
          .padding()
      }
    }
  }
}
/*
### Panel 5: Using Gimmees
- **Title:** Using Gimmees
- **Content:** Explain the concept of gimmees and how players can use them.
  - "You start each game with a few gimmees, which let you replace a question. Long-press an unplayed cell to use a gimmee. If you get stuck, gimmees can save the day!"
*/
struct OB05: View {
  @Binding var isPresented:Bool
  var body: some View {
    ZStack {
      WrappedDismissButton(isPresented: $isPresented)
      VStack {
        Image("Onboarding5")
          .resizable()
          .scaledToFit()
          .padding()
        Text("Using Gimmees")
          .font(.title)
          .padding()
        Text("You start each game with a few gimmees, which let you replace a question. Long-press an unplayed cell to use a gimmee. If you get stuck, gimmees can save the day!")
          .padding()
      }
    }
  }
}
/*
### Panel 6: Winning & Losing
- **Title:** Winning & Losing
- **Content:** Outline the win and lose conditions.
  - "To win, complete a path of correct answers from one corner to the opposite diagonal corner. The game is over if there's no possible winning path and you have no gimmees left."
*/
struct OB06: View {
  @Binding var isPresented:Bool
  var body: some View {
    ZStack {
      WrappedDismissButton(isPresented: $isPresented)
      VStack {
        Image("Onboarding6")
          .resizable()
          .scaledToFit()
          .padding()
        Text("Winning & Losing")
          .font(.title)
          .padding()
        Text("To win, complete a path of correct answers from one corner to the opposite diagonal corner. The game is over if there's no possible winning path and you have no gimmees left.")
          .padding()
      }
    }
  }
}
/*
### Panel 7: Difficulty Levels & Game Variants
- **Title:** Difficulty & Variants
- **Content:** Briefly describe the difficulty settings and game variants.
  - "Choose your difficulty level: easy, normal, or hard. Experiment with different game variants like 'All Questions Face Up' or 'All Questions Face Down' for extra challenges. Good luck!"
*/
struct OB07: View {
    @Binding var isPresented:Bool
    var body: some View {
      ZStack {
        WrappedDismissButton(isPresented: $isPresented)
        VStack {
          Image("Onboarding7")
            .resizable()
            .scaledToFit()
            .padding()
          Text("Difficulty & Variants")
            .font(.title)
            .padding()
          Text("Choose your difficulty level: easy, normal, or hard. Experiment with different game variants like 'All Questions Face Up' or 'All Questions Face Down' for extra challenges. Good luck!")
            .padding()
        }
      }
    }
  }

struct OnboardingScreen: View {
  @Binding var  isPresented: Bool
  var body: some View {
    TabView {
      OB01(isPresented: $isPresented)
        .tag(mkID())
      OB02(isPresented: $isPresented)
        .tag(mkID())
      OB03(isPresented: $isPresented)
        .tag(mkID())
      OB04(isPresented: $isPresented)
        .tag(mkID())
      OB05(isPresented: $isPresented)
        .tag(mkID())
      OB06(isPresented: $isPresented)
        .tag(mkID())
      OB07(isPresented: $isPresented)
        .tag(mkID())
    }
    .background(Color.white.opacity(0.1))
    .tabViewStyle(PageTabViewStyle())
  }
}
#Preview {
  OnboardingScreen(isPresented: .constant(true))
}
