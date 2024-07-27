//
//  FrontView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//
import SwiftUI

struct GameScreen: View {
  @Bindable var gs: GameState
  @Bindable var chmgr: ChaMan
  @Binding  var topics: [String]
  @Binding var size:Int
  let onTapGesture: (_ row:Int, _ col:Int ) -> Bool
  
 // @AppStorage("border") private var border = 3.0
  
  @State private var firstMove = true
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
  
  
  var bodyMsg: String {
    let t =  """
    That was game \(gs.playcount) of which you've won \(gs.woncount) and lost \(gs.lostcount) games
"""
    return t
  }
  
  var body: some View {
    VStack {
      Text("QandA \(AppVersionProvider.appVersion()) by Freeport Software").font(.caption2)
      topButtonsVeew // down below
        .padding(.horizontal)
      ScoreBarView(gs: gs)
      if gs.boardsize > 1 {
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
    .onChange(of:gs.cellstate) {
                                 //print("//GameScreen onChangeof(CellState) to \(gs.cellstate)")
                                 onChangeOfCellState()
                               }
                               .onChange(of:gs.boardsize) {
                                 print("//GameScreen onChangeof(Size) to \(gs.boardsize)")
                                 onBoardSizeChange ()
                               }
                               .sheet(isPresented: $showSettings){
                               SettingsScreen(chmgr: chmgr, gs: gs)//,
//                                                    onExit: {t in
//                                   print("//GameSettingsScreen onExit closure topics:\(t) ")
//                                   gs.topicsinplay = t //was
//                                   //  onGameSettingsExit (t)
                                 //})
                               }
                               .fullScreenCover(isPresented: $showingHelp ){
                                 HowToPlayScreen (chmgr: chmgr, isPresented: $showingHelp)
                               }
                               .sheet(isPresented: $showAllocatorView) {
                                 AllocatorView(chmgr: chmgr, gs: gs)
                                   .presentationDetents([.fraction(0.25)])
                               }
                               .onDisappear {
                                 print("Yikes the GameScreen is Disappearing!")
                               }
    
  }
  
  var mainGridVeew: some View {
    GeometryReader { geometry in
      let _ = print("gs.boardsize \(gs.boardsize) gs.board.count \(gs.board.count) ")
      let totalSpacing = spacing * CGFloat(gs.boardsize - 1)
      let axisSize = min(geometry.size.width, geometry.size.height) - totalSpacing
      let cellSize = (axisSize / CGFloat(gs.boardsize)) * shrinkFactor  // Apply shrink factor
      VStack(alignment:.center, spacing: spacing) {
        ForEach(0..<gs.boardsize, id: \.self) { row in
          HStack(spacing: spacing) {
            ForEach(0..<gs.boardsize, id: \.self) { col in
              // i keep getting row and col out of bounds, so clamp it
              if row < gs.boardsize  && col < gs.boardsize   {  
                makeOneCellVue(row:row,col:col,
                               challenge:gs.board[row][col],
                               status:gs.cellstate[row][col],
                               cellSize: cellSize)
              }
            }
          }
        }
      }
      .padding()
    }
  }
  var topButtonsVeew : some View{
    HStack {
      if gs.gamestate !=  StateOfPlay.playingNow {
        //Start Game
        Button(action: {
          withAnimation {
            let ok =  onStartGame(boardsize: gs.boardsize)
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
          onEndGamePressed()  //should estore consistency
          chmgr.checkTopicConsistency("GameScreen EndGamePressed")
        //  print("//GameScreen return from onEndGamePressed")
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
      .disabled(gs.gamestate == .playingNow)
      .opacity(gs.gamestate != .playingNow ? 1 : 0.5)
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
    if gs.playcount == 0 {
      print("//GameScreen OnAppear Coldstart size:\(gs.boardsize) topics: \(topics)")
    } else {
      print("//GameScreen OnAppear Warmstart size:\(gs.boardsize) topics: \(topics)")
    }
  }
  
  func onCantStartNewGameAction() {
    print("//GameScreen onCantStartNewGameAction")
    gs.clearAllCells()
    showCantStartAlert = false
  }
  
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
  
  func onBoardSizeChange() {
   
  }
  
  func onChangeOfCellState() {
    if isWinningPath(in:gs.cellstate) {
      print("--->YOU WIN")
      showWinAlert = true
    } else {
      if !isPossibleWinningPath(in:gs.cellstate) {
        print("--->YOU LOSE")
        showLoseAlert = true
      }
    }
  }
  func onDump() {
    chmgr.dumpTopics()
  }
  func onStartGame(boardsize:Int ) -> Bool {
    print("//GameScreen onStartGame before  topics: \(gs.topicsinplay) size:\( boardsize)")
    // chmgr.dumpTopics()
    let ok = gs.setupForNewGame(boardsize:boardsize,chmgr: chmgr )
    print("//GameScreen onStartGame after")
    // chmgr.dumpTopics()
    if !ok {
      print("Failed to allocate \(gs.boardsize*gs.boardsize) challenges for topic \(topics.joined(separator: ","))")
      print("Consider changing the topics in setting and trying again ...")
    } else {
      firstMove = true
    }
    return ok
  }
  func endGame(status:StateOfPlay){
    gs.teardownAfterGame(state: status, chmgr: chmgr)
  }
}
private extension GameScreen {
  func makeOneCellVue(row:Int,
                      col:Int ,
                      challenge:Challenge,
                      status:ChallengeOutcomes,
                      cellSize: CGFloat) -> some View {
    let colormix = colorForTopic(challenge.topic, gs: gs)
    return VStack {
      Text(//hideCellContent ||hideCellContent ||
        ( !gs.faceup) ? " " : challenge.question )
      .font(.caption)
      .padding(10)
      .frame(width: cellSize, height: cellSize)
      .background(colormix.0)
      .foregroundColor(colormix.1)
      .border(status.borderColor , width: CGFloat(11-gs.boardsize)) //3=8,8=3
      .cornerRadius(8)
      .opacity(gs.gamestate == .playingNow ? 1.0:0.3)
    }
    // for some unknown reason, the tap surface area is bigger if placed outside the VStack
    .onTapGesture {
      var  tap = false
      if  gs.gamestate == .playingNow &&
           ( gs.cellstate[row][col] == .playedCorrectly ||
             gs.cellstate[row][col] == .playedIncorrectly)  {
      
        
      }
      if  gs.gamestate == .playingNow &&
            gs.cellstate[row][col] == .unplayed {
        if gs.startincorners&&firstMove{
          tap = row==0&&col==0  ||
          row==0 && col == gs.boardsize-1 ||
          row==gs.boardsize-1 && col==0 ||
          row==gs.boardsize-1 && col == gs.boardsize - 1
        }
        else {
          tap = true
        }
      }
      if tap {  firstMove =    onTapGesture(row,col)
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
    ForEach([3, 4, 5, 6,7,8], id: \.self) { s in
      GameScreen(
        gs:GameState(size: 1, topics:["Fun"], challenges: [Challenge.complexMock]),
        chmgr: ChaMan(playData: PlayData.mock),
        topics: .constant(["Actors", "Animals", "Cars"]), size:.constant(s),
        onTapGesture: { row,col in
          print("Tapped cell with challenge \(row) \(col)")
          return false
        }
      )
      .previewLayout(.fixed(width: 300, height: 300))
      .previewDisplayName("Size \(s)x\(s)")
    }
  }
}



