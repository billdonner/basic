//
//  FrontView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//
import SwiftUI

struct GameScreen: View {
  let gameBoard: GameBoard
  let challengeManager: ChallengeManager
  @Binding  var size: Int
  @Binding  var topics: [String]
  let onTapGesture: (_ row:Int, _ col:Int ) -> Void
  
 
  
  @State private var startAfresh = true
  @State private var showCantStartAlert = false
  @State private var showSettings = false
  @State private var showingHelp = false
  @State private var showWinAlert = false
  @State private var showLoseAlert = false
  @State private var showAllocatorView = false
  
  private let spacing: CGFloat = 5
  // Adding a shrink factor to slightly reduce the cell size
  private let shrinkFactor: CGFloat = 0.9
  @AppStorage("faceUpCards")   var faceUpCards = true
  @AppStorage("boardSize")  var boardSize = 6
  
  
  var body: some View {
    VStack {
      topButtonsVeew // down below
        .padding(.horizontal)
      ScoreBarView(gb: gameBoard)
      if gameBoard.size > 1 {
          mainGridVeew
      } 
      else {
          loadingVeew
      }
      Spacer()
      Divider()
      Button (action:{ showAllocatorView = true}) {
        Text ("Index of Topics")
      }
    }
    .youWinAlert(isPresented: $showWinAlert, title: "You Win", bodyMessage: "that was game \(gameBoard.playcount)", buttonTitle: "OK"){
      onYouWin()
    }
    .youLoseAlert(isPresented: $showLoseAlert, title: "You Lose", bodyMessage: "that was game \(gameBoard.playcount)", buttonTitle: "OK"){
      onYouLose()
    }
    .onChange(of:gameBoard.cellstate) { 
        print("//GameScreen onChange(ofCellState)")
      onChangeOfCellState()
    }
    .sheet(isPresented: $showSettings){
    
      GameSettingsScreen(challengeManager: challengeManager, gb: gameBoard, ourTopics: topics) {t in

        print("//GameScreen isPresented closure topics:\(t) ")        
        onGameSettingsExit (t)
      }
    }
    .fullScreenCover(isPresented: $showingHelp ){
      HowToPlayScreen (isPresented: $showingHelp)
    }
    .onChange(of: boardSize) {
      print("//GameScreen onChange(ofBoardSize:\(boardSize)")
      onBoardSizeChange ()
    }
    .sheet(isPresented: $showAllocatorView) {
      AllocatorView(challengeManager: challengeManager, gameBoard: gameBoard)
        .presentationDetents([.fraction(0.25)])
    }
  }
  
  var mainGridVeew: some View {
    GeometryReader { geometry in
      let totalSpacing = spacing * CGFloat(gameBoard.size - 1)
      let axisSize = min(geometry.size.width, geometry.size.height) - totalSpacing
      let cellSize = (axisSize / CGFloat(gameBoard.size)) * shrinkFactor  // Apply shrink factor
      VStack(alignment:.center, spacing: spacing) {
        ForEach(0..<gameBoard.size, id: \.self) { row in
          HStack(spacing: spacing) {
            ForEach(0..<gameBoard.size, id: \.self) { col in
              makeOneCellVue(row:row,col:col,challenge: gameBoard.board[row][col],status:gameBoard.cellstate[row][col], cellSize: cellSize)
            }
          }
        }
      }
      .padding()
    }
  }
  var topButtonsVeew : some View{
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
      }
      //SETTINGS
      Button(action: {  showSettings = true }) {
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
    print("//GameScreen EndGamePressed")
    endGame(status:.justAbandoned)
    // hideCellContent = true
  }
  func onAppearAction () { 
    // on a completely cold start
    if gameBoard.playcount == 0 {
      print("//GameScreen OnAppear Coldstart size:\(size) topics: \(topics)")
      // setup a blank board, dont allocate anything, wait for the start button
      gameBoard.reinit(size: size, topics: topics, challenges: [],dontPopulate: true)
      
    } else {
      print("//GameScreen OnAppear Warmstart size:\(size) topics: \(topics)")
    }
    
//    let ok =   startNewGame(size: size, topics: topics)
//    if !ok  {
//      //TODO: Alert the User first game cant load, this is fatal
//      showCantStartAlert = true
//    }
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
  func onGameSettingsExit(_ topics:[String]) {
    // here on the way out
    print("//GameScreen onGameSettingsExit topics:\(topics)")
//    let ok =  startFresh()
//    if !ok { print ("Cant reset after gamesettings")}
  }
  
  func onBoardSizeChange() {
    gameBoard.size = boardSize
//    let ok =  startFresh()
//    if !ok { print ("Cant reset after boarSizeChange")}
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
    print("//GameScreen onStartGame   topics: \(gameBoard.topicsinplay)")
  }
  func onCantStartNewGame() {
    clearAllCells()
    gameBoard.gamestate =  GameState.justAbandoned
  }
  
  func onChangeOfCellState() {
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
}

private extension GameScreen {
  func makeOneCellVue(row:Int,
                      col:Int ,
                      challenge:Challenge, status:ChallengeOutcomes,  cellSize: CGFloat) -> some View {
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
    }
    // for some unknown reason, the tap surface area is bigger if placed outside the VStack
      .onTapGesture {
        if  gameBoard.gamestate == .playingNow &&
              gameBoard.cellstate[row][col] == .unplayed {
          onTapGesture(row,col)
        }
      }
   
  }// make one cell
    var loadingVeew: some View {
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
}

private extension GameScreen {
  func startFresh()->Bool {
    startNewGame(size:size, topics:topics)
  }
  func startNewGame(size: Int, topics: [String]) -> Bool {
    if let challenges = challengeManager.allocateChallenges(forTopics: topics, count: size * size) {
      gameBoard.reinit(size: size, topics: topics, challenges: challenges)
      gameBoard.saveGameBoard()
      return true
    } else {
      print("Failed to allocate \(size) challenges for topic \(topics.joined(separator: ","))")
      print("Consider changing the topics in setting...")
    }
    return false
  }

  
  func endGame(status:GameState){
    gameBoard.windDown(status, challengeManager: challengeManager)
  }

  
  func clearAllCells() {
    for row in 0..<gameBoard.size {
      for col in 0..<gameBoard.size {
        gameBoard.cellstate[row][col] = .unplayed
       
      }
    }
    gameBoard.saveGameBoard()
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
    gameBoard.saveGameBoard()
  }
}
// Preview Provider for SwiftUI preview
struct GameScreen_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ForEach([3, 4, 5, 6], id: \.self) { size in
        GameScreen(
          gameBoard:GameBoard(size: 1, topics:["Fun"], challenges: [Challenge.complexMock]),
          challengeManager: ChallengeManager(playData: PlayData.mock),
          
          size: .constant(size),
          topics: .constant(["Actors", "Animals", "Cars"]),
          onTapGesture: { row,col in
            print("Tapped cell with challenge \(row) \(col)")
          }
        )
        .previewLayout(.fixed(width: 300, height: 300))
        .previewDisplayName("Size \(size)x\(size)")
      }
    }
  }
}
//challenge.id + "&" + gameBoard.status[row][col].id)
//"\(status.val) " + "\(playCount )" +

