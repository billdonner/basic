//
//  FrontView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//
import SwiftUI

struct FrontView: View {
    let size: Int
    let topics: [String]
    @Binding var playCount: Int
  let tapGesture: (_ row:Int, _ col:Int ) -> Void
    @EnvironmentObject var appColors: AppColors
    @EnvironmentObject var challengeManager: ChallengeManager
    @EnvironmentObject var gameBoard: GameBoard
    @State private var hideCellContent = true
    @State private var showingAlert = false
    @State private var showingSettings = false
    private let spacing: CGFloat = 5
    // Adding a shrink factor to slightly reduce the cell size
    private let shrinkFactor: CGFloat = 0.9
  @AppStorage("faceUpCards")   var faceUpCards = false
    var body: some View {
        VStack {
        buttons // down below
            .padding(.horizontal)
          ScoreBarView(hideCellContent: $hideCellContent)
          if gameBoard.size > 1 {
                GeometryReader { geometry in
                    let totalSpacing = spacing * CGFloat(gameBoard.size - 1)
                    let axisSize = min(geometry.size.width, geometry.size.height) - totalSpacing
                    let cellSize = (axisSize / CGFloat(gameBoard.size)) * shrinkFactor  // Apply shrink factor
                  VStack(alignment:.center, spacing: spacing) {
                            ForEach(0..<gameBoard.size, id: \.self) { row in
                                HStack(spacing: spacing) {
                                    ForEach(0..<gameBoard.size, id: \.self) { col in
                                      makeOneCell(row:row,col:col,challenge: gameBoard.board[row][col],status:gameBoard.cellstate[row][col], cellSize: cellSize)
                                    }
                                }
                            }
                        }
                    .padding()
                }.sheet(isPresented: $showingSettings){
                  GameSettingsScreen(ourTopics: topics) {
                    //needs ehlep
                   // print("GameSettings returned")
                  }
                }
            } else {
                Text("Loading...")
                    .onAppear {
                      let ok =   startNewGame(size: size, topics: topics)
                      if !ok  {
                        //TODO: Alert the User first game cant load, this is fatal
                        showingAlert = true
                      }
                    }
                    .alert("Can't start new Game from this download, sorry. \nWe will reuse your last download to start afresh.",isPresented: $showingAlert){
                      Button("OK", role: .cancel) {
                        challengeManager.resetAllChallengeStatuses(gameBoard: gameBoard)
                        hideCellContent = true
                        clearAllCells()
                        showingAlert = false } //stick the right here
                    }
            }
            Spacer()
            Divider()
            VStack {
              AllocatorView(playCount:$playCount)
            }.frame(height: 150)
        }
    }
    
    func startNewGame(size: Int, topics: [String]) -> Bool {
      if let challenges = challengeManager.allocateChallenges(forTopics: topics, count: size * size) {
      
          gameBoard.reinit(size: size, topics: topics, challenges: challenges)
          //randomlyMarkCells()
          return true
        } else {
          print("Failed to allocate \(size) challenges for topic \(topics.joined(separator: ","))")
          print("Consider changing the topics in setting...")
        }
      return false
    }
    
    func endGame() {
            let unplayedChallenges = gameBoard.resetBoardReturningUnplayed()
            challengeManager.resetChallengeStatuses(at: unplayedChallenges.map { challengeManager.getAllChallenges().firstIndex(of: $0)! })
    }
    
    func clearAllCells() {
        for row in 0..<gameBoard.size {
            for col in 0..<gameBoard.size {
              gameBoard.cellstate[row][col] = .unplayed
            }
        }
    }
    
    func randomlyMarkCells() {
        let totalCells = gameBoard.size * gameBoard.size
        let correctCount = totalCells / 3
        let incorrectCount = totalCells / 3
        
        var correctMarked = 0
        var incorrectMarked = 0
        
        for row in 0..<gameBoard.size {
            for col in 0..<gameBoard.size {
                if correctMarked < correctCount {
                  gameBoard.cellstate[row][col] = .playedCorrectly
                    correctMarked += 1
                } else if incorrectMarked < incorrectCount {
                  gameBoard.cellstate[row][col]  = .playedIncorrectly
                    incorrectMarked += 1
                } else {
                  gameBoard.cellstate[row][col]  = .unplayed 
                }
            }
        }
    }
     
  var buttons : some View{
    HStack {
      //Start Game
        Button(action: {
          let ok =   startNewGame(size: size, topics: topics)
            hideCellContent = false
          if !ok {
            // ALERT HERE and possible reset
            showingAlert = true
          }
        }) {
            Text("Start Game")
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(!hideCellContent)
        .opacity(hideCellContent ? 1 : 0.5)
        .alert("Can't start new Game - consider changing the topics or hit Full Reset",isPresented: $showingAlert){
          Button("OK", role: .cancel) {
            hideCellContent = true
            clearAllCells()
          }
        }
      // END GAME
        Button(action: {
            endGame()
          hideCellContent = true
        }) {
            Text("End Game")
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(hideCellContent)
        .opacity(!hideCellContent ? 1 : 0.5)
        //RESET
        Button(action: {
          let unplayedChallenges = gameBoard.resetBoardReturningUnplayed()
          challengeManager.resetChallengeStatuses(at: unplayedChallenges.map { challengeManager.getAllChallenges().firstIndex(of: $0)! })
            hideCellContent = true
            clearAllCells()
        }) {
            Text("Full Reset")
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(!hideCellContent)
        .opacity(hideCellContent ? 1 : 0.5)
      
      //SETTINGS
      Button(action: {
       showingSettings = true
      }) {
          Text("Settings")
              .padding()
              .background(Color.white)
              .foregroundColor(.black)
              .border(Color.black,width:4)
              .cornerRadius(8)
      }
      .disabled(!hideCellContent)
      .opacity(hideCellContent ? 1 : 0.5)
      
    }
    
    
  }
  fileprivate func makeOneCell(row:Int,col:Int , challenge:Challenge, status:ChallengeOutcomes,  cellSize: CGFloat) -> some View {
      let colormix = appColors.colorFor(topic: challenge.topic)
        return VStack {
          Text(//"\(status.val) " + "\(playCount )" +
            ((hideCellContent || !faceUpCards) ? " " : challenge.question ))
                //challenge.id + "&" + gameBoard.status[row][col].id)
                .font(.caption)
                .padding(10)
                .frame(width: cellSize, height: cellSize)
                .background(colormix?.backgroundColor)
                .foregroundColor(colormix?.foregroundColor)
                .border(status.borderColor , width: 8)
                .cornerRadius(8)
                .onTapGesture {
                  if !hideCellContent {
                    tapGesture(row,col)
                  }
                }
        }
    }
    
}
// Preview Provider for SwiftUI preview
struct FrontView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach([3, 4, 5, 6], id: \.self) { size in
                FrontView(
                    size: size,
                    topics: ["Actors", "Animals", "Cars"], playCount: .constant(3),
                    tapGesture: { row,col in
                      print("Tapped cell with challenge \(row) \(col)")
                    }
                )  .environmentObject(GameBoard(size: 1, topics:["Fun"], challenges: [Challenge.mock]))
                .environmentObject(ChallengeManager())  // Ensure to add your ChallengeManager
                .previewLayout(.fixed(width: 300, height: 300))
                .previewDisplayName("Size \(size)x\(size)")
            }
        }
    }
}

