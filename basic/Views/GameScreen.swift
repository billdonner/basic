//
//  FrontView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//
import SwiftUI

struct GameScreen: View {
  @Bindable var gameBoard: GameBoard
  @Bindable var chmgr: ChaMan
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
  
  var bodyMsg: String {
  let t =  """
    That was game \(gameBoard.playcount) of which you've won \(gameBoard.woncount) and lost \(gameBoard.lostcount) games
"""
  return t
  }
  
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
    .youWinAlert(isPresented: $showWinAlert, title: "You Win", 
                 bodyMessage: bodyMsg, buttonTitle: "OK"){
      onYouWin()
    }
    .youLoseAlert(isPresented: $showLoseAlert, title: "You Lose", 
                  bodyMessage: bodyMsg, buttonTitle: "OK"){
      onYouLose()
    }
    .onChange(of:gameBoard.cellstate) { 
        print("//GameScreen onChangeof(CellState)")
      onChangeOfCellState()
    }
    .onChange(of:gameBoard.size) {
        print("//GameScreen onChangeof(Size)")
    }
    .sheet(isPresented: $showSettings){
      GameSettingsScreen(chmgr: chmgr, gameBoard: gameBoard, ourTopics: topics,onExit: {t in
        print("//GameScreen isPresented closure topics:\(t) ")
        onGameSettingsExit (t)
      })
    }
    .fullScreenCover(isPresented: $showingHelp ){
      HowToPlayScreen (chmgr: chmgr, isPresented: $showingHelp)
    }
    .onChange(of: boardSize) {
      print("//GameScreen onChange(ofBoardSize:\(boardSize))")
      onBoardSizeChange ()
    }
    .sheet(isPresented: $showAllocatorView) {
      AllocatorView(chmgr: chmgr, gameBoard: gameBoard)
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
            let ok =  onStartGame()
            if !ok {
              showCantStartAlert = true
            }
          }
        }) {
          Text("Start Game")
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .alert("Can't start new Game - consider changing the topics or hit Full Reset",isPresented: $showCantStartAlert){
          Button("OK", role: .cancel) {
            withAnimation {
              onCantStartNewGameAction()
            }
          }
        }
      } else {
        // END GAME
        Button(action: {
         // withAnimation {
            onEndGamePressed()
            print("//GameScreen return from onEndGamePressed")
       //   }
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

  func onAppearAction () { 
    // on a completely cold start
    if gameBoard.playcount == 0 {
      print("//GameScreen OnAppear Coldstart size:\(gameBoard.size) topics: \(topics)")
      // setup a blank board, dont allocate anything, wait for the start button
      //gameBoard.reinit(size: size, topics: topics, challenges: [],dontPopulate: true)
      
    } else {
      print("//GameScreen OnAppear Warmstart size:\(gameBoard.size) topics: \(topics)")
    }

  }
  

 
  func onCantStartNewGameAction() {
    print("//GameScreen onCantStartNewGameAction")
    gameBoard.clearAllCells()
    showCantStartAlert = false
  } //stick the right here
  

  func onYouWin () {
    endGame(status: .justWon)
  }
  
  func onYouLose () {
    endGame(status: .justLost)
  }
  func onEndGamePressed () {
    print("//GameScreen EndGamePressed")
    endGame(status:.justAbandoned)
  }

  func onGameSettingsExit(_ topics:[String]) {
    // here on the way out
    print("//GameScreen onGameSettingsExit topics:\(topics)")
  }
  
  func onBoardSizeChange() {
    gameBoard.size = boardSize
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
  func onDump() {
    chmgr.dumpTopics()
  }
  func onStartGame() -> Bool {
    let ok = gameBoard.setupForNewGame(chmgr: chmgr )
    print("//GameScreen onStartGame   topics: \(gameBoard.topicsinplay)")
    chmgr.dumpTopics()
    if !ok {
      print("Failed to allocate \(gameBoard.size*gameBoard.size) challenges for topic \(topics.joined(separator: ","))")
      print("Consider changing the topics in setting and trying again ...")
    }
    return ok
  }
  
  
  func endGame(status:GameState){
    gameBoard.teardownAfterGame(state: status, chmgr: chmgr)
  }
  
}
private extension GameScreen {
  func makeOneCellVue(row:Int,
                      col:Int ,
                      challenge:Challenge, status:ChallengeOutcomes,  cellSize: CGFloat) -> some View {
    let colormix = colorForTopic(challenge.topic, gb: gameBoard)
    return VStack {
      Text(//hideCellContent ||hideCellContent ||
        ( !faceUpCards) ? " " : challenge.question )
      .font(.caption)
      .padding(10)
      .frame(width: cellSize, height: cellSize)
          .background(colormix.0)
          .foregroundColor(colormix.1)
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

// Preview Provider for SwiftUI preview
#Preview ("GameScreen") {
    Group {
      ForEach([3, 4, 5, 6], id: \.self) { s in
        GameScreen(
          gameBoard:GameBoard(size: 1, topics:["Fun"], challenges: [Challenge.complexMock]),
          chmgr: ChaMan(playData: PlayData.mock),
          topics: .constant(["Actors", "Animals", "Cars"]),
          onTapGesture: { row,col in
            print("Tapped cell with challenge \(row) \(col)")
          }
        )
        .previewLayout(.fixed(width: 300, height: 300))
        .previewDisplayName("Size \(s)x\(s)")
      }
    }
  }

 

