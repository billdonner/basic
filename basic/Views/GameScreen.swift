//
//  FrontView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//
import SwiftUI

struct GameScreen: View {
  let size: Int
  let topics: [String]
  @Binding var playCount: Int
  let tapGesture: (_ row:Int, _ col:Int ) -> Void
  
  @EnvironmentObject var challengeManager: ChallengeManager
  @EnvironmentObject var gameBoard: GameBoard
  
  @State private var startAfresh = true
  @State private var showCantStartAlert = false
  @State private var showingSettings = false
  @State private var showingHelp = false
  @State private var showWinAlert = false
  @State private var showLoseAlert = false
  @State private var showAllocatorView = false
  
  private let spacing: CGFloat = 5
  // Adding a shrink factor to slightly reduce the cell size
  private let shrinkFactor: CGFloat = 0.9
  @AppStorage("faceUpCards")   var faceUpCards = false
  @AppStorage("boardSize")  var boardSize = 6
  
  
  var body: some View {
    VStack {
      topButtons // down below
        .padding(.horizontal)
      ScoreBarView()
      if gameBoard.size > 1 {
        mainGrid
      } else {
        Text("Loading...")
          .onAppear {
            onAppearAction()
          }
          .alert("Can't start new Game from this download, sorry. \nWe will reuse your last download to start afresh.",isPresented: $showCantStartAlert){
            Button("OK", role: .cancel) {
              onCantStartNewGameAction()
            }
          }
      }
      Spacer()
      Divider()
      Button (action:{ showAllocatorView = true}) {
        Text ("Index of Topics")
      }
    }
    .youWinAlert(isPresented: $showWinAlert, title: "You Win", bodyMessage: "a fine job", buttonTitle: "gamescreen OK"){
      onYouWin()
    }
    .youLoseAlert(isPresented: $showLoseAlert, title: "You Lose", bodyMessage: "try again", buttonTitle: "gamescreen OK"){
      onYouLose()
    }
    .onChange(of:gameBoard.cellstate) {
      if isWinningPath(in:gameBoard.cellstate) {
        print("--->YOU WIN")
        showWinAlert = true
      } else {
        if !isPossibleWinningPath(in:gameBoard.cellstate) {
          print("--->YOU LOSE")
          showLoseAlert = true
        }
      }
    }
    .sheet(isPresented: $showAllocatorView) {
      AllocatorView(playCount:$playCount)
        .presentationDetents([.fraction(0.25)])
    }
  }
  
  var mainGrid: some View {
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
        onGameSettingsExit()
      }
    }
    .sheet(isPresented: $showingHelp ){
      HowToPlayScreen (isPresented: $showingHelp)
    }
    .onChange(of: boardSize) {
      onBoardSizeChange ()
    }
  }
  var topButtons : some View{
    HStack {
      if gameBoard.gamestate !=  GameState.playingNow {
        //Start Game
        Button(action: {
          withAnimation {
            onStartGame()
          }
        }) {
          Text("Start Game")
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        //        .disabled(!hideCellContent)
        //        .opacity(gameBoard.gamestate == .playingNow ? 1 : 0.5)
        .alert("Can't start new Game - consider changing the topics or hit Full Reset",isPresented: $showCantStartAlert){
          Button("OK", role: .cancel) {
            withAnimation {
              onCantStartNewGame()
            }
          }
        }
      } else {
        // END GAME
        Button(action: {
          withAnimation {
            onEndGamePressed()
          }
        }) {
          Text("End Game")
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        //.disabled(hideCellContent)
        //.opacity(!hideCellContent ? 1 : 0.5)
      }
      //SETTINGS
      Button(action: {  showingSettings = true }) {
        Text("Settings")
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
      .disabled(gameBoard.gamestate == .playingNow)
      .opacity(gameBoard.gamestate != .playingNow ? 1 : 0.5)
      //Help
      Button(action: { showingHelp = true }) {
        Text("Help")
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
    }
  }
}
extension GameScreen /* actions */ {
  func onEndGamePressed () {
    endGame(status:.justAbandoned)
    // hideCellContent = true
  }
  func onAppearAction () {
    let ok =   startNewGame(size: size, topics: topics)
    if !ok  {
      //TODO: Alert the User first game cant load, this is fatal
      showCantStartAlert = true
    }
  }
  func onCantStartNewGameAction() {
    challengeManager.resetAllChallengeStatuses(gameBoard: gameBoard)
    // hideCellContent = true
    clearAllCells()
    showCantStartAlert = false
  } //stick the right here
  func onYouWin () {
    endGame(status: .justWon)
  }
  func onYouLose () {
    endGame(status: .justLost)
  }
  func onGameSettingsExit() {
    // here on the way out
    let ok =  startFresh()
    if !ok { print ("Cant reset after gamesettings")}
  }
  
  func onBoardSizeChange() {
    gameBoard.size = boardSize
    let ok =  startFresh()
    if !ok { print ("Cant reset after boarSizeChange")}
  }
  
  func onStartGame(){
    let ok =   startFresh()
    //hideCellContent = false
    if !ok {
      // ALERT HERE and possible reset
      showCantStartAlert = true
      gameBoard.gamestate =  GameState.justAbandoned
    } else {
      gameBoard.gamestate =  GameState.playingNow
    }
  }
  func onCantStartNewGame() {
    clearAllCells()
    gameBoard.gamestate =  GameState.justAbandoned
  }
}

private extension GameScreen {
  func makeOneCell(row:Int,col:Int , challenge:Challenge, status:ChallengeOutcomes,  cellSize: CGFloat) -> some View {
    let colormix = AppColors.colorFor(topic: challenge.topic)
    return VStack {
      Text(//hideCellContent ||hideCellContent ||
        ( !faceUpCards) ? " " : challenge.question )
      .font(.caption)
      .padding(10)
      .frame(width: cellSize, height: cellSize)
      //      .background(colormix?.backgroundColor)
      //      .foregroundColor(colormix?.foregroundColor)
      .border(status.borderColor , width: 8)
      .cornerRadius(8)
      .opacity(gameBoard.gamestate == .playingNow ? 1.0:0.3)
      .onTapGesture {
        if  gameBoard.gamestate == .playingNow {
          tapGesture(row,col)
        }
      }
    }
  }// make one cell
}

private extension GameScreen {
  func startFresh()->Bool {
    startNewGame(size:size, topics:topics)
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
  
  func endGame(status:GameState) {
    let unplayedChallenges = gameBoard.resetBoardReturningUnplayed()
    challengeManager.resetChallengeStatuses(at: unplayedChallenges.map { challengeManager.getAllChallenges().firstIndex(of: $0)! })
    gameBoard.gamestate = status
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
}
// Preview Provider for SwiftUI preview
struct GameScreen_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ForEach([3, 4, 5, 6], id: \.self) { size in
        GameScreen(
          size: size,
          topics: ["Actors", "Animals", "Cars"], playCount: .constant(3),
          tapGesture: { row,col in
            print("Tapped cell with challenge \(row) \(col)")
          }
        )
        .environmentObject(GameBoard(size: 1, topics:["Fun"], challenges: [Challenge.complexMock]))
        .environmentObject(ChallengeManager())  // Ensure to add your ChallengeManager
        .previewLayout(.fixed(width: 300, height: 300))
        .previewDisplayName("Size \(size)x\(size)")
      }
    }
  }
}
//challenge.id + "&" + gameBoard.status[row][col].id)
//"\(status.val) " + "\(playCount )" +
