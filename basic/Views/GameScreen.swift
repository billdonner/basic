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
  let onSingleTap: (_ row:Int, _ col:Int ) -> Bool
  
  @State private var firstMove = true
  @State private var startAfresh = true
  @State private var showCantStartAlert = false
  @State private var showSettings = false
  @State private var showingHelp = false
  @State private var showWinAlert = false
  @State private var showLoseAlert = false

  var bodyMsg: String {
    let t =  """
    That was game \(gs.gamenumber) of which you've won \(gs.woncount) and lost \(gs.lostcount) games
"""
    return t
  }
  
  var body: some View {
    VStack {
      VStack {
        Text("QandA \(AppVersionProvider.appVersion()) by Freeport Software").font(.caption2)
        topButtonsVeew // down below
          .padding(.horizontal)
        ScoreBarView(gs: gs)
        if gs.boardsize > 1 {
          VStack(alignment: .center){
            MainGridView(gs: gs, chmgr:chmgr,
                         firstMove: $firstMove, onSingleTap: onSingleTap)//.border(Color.red)
          }
        }
        else {
          loadingVeew
        }
      }

      .onChange(of:gs.cellstate) {
        onChangeOfCellState()
      }
      .onChange(of:gs.boardsize) {
        print("//GameScreen onChangeof(Size) to \(gs.boardsize)")
        onBoardSizeChange ()
      }
      .sheet(isPresented: $showSettings){
        SettingsScreen(chmgr: chmgr, gs: gs)
      }
      .fullScreenCover(isPresented: $showingHelp ){
        HowToPlayScreen (chmgr: chmgr, isPresented: $showingHelp)
          .statusBar(hidden: true)
      }
      
      .onDisappear {
        print("Yikes the GameScreen is Disappearing!")
      }
      
    }// outer vstack
    
    .youWinAlert(isPresented: $showWinAlert, title: "You Win",
                 bodyMessage: bodyMsg, buttonTitle: "OK"){
      onYouWin()
    }
                 .youLoseAlert(isPresented: $showLoseAlert, title: "You Lose",
                               bodyMessage: bodyMsg, buttonTitle: "OK"){
                   onYouLose()
                 }
    Spacer()
    TopicIndexView(gs:gs, chmgr: chmgr)//.frame(height:200)
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
            
            chmgr.checkAllTopicConsistency("GameScreen StartGamePressed")
            assert(gs.checkVsChaMan(chmgr: chmgr))
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
          assert(gs.checkVsChaMan(chmgr: chmgr)) //cant check after endgamepressed
          onEndGamePressed()  //should estore consistency
          chmgr.checkAllTopicConsistency("GameScreen EndGamePressed")
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
    if gs.gamenumber == 0 {
      print("//GameScreen OnAppear Coldstart size:\(gs.boardsize) topics: \(topics)")
    } else {
      print("//GameScreen OnAppear Warmstart size:\(gs.boardsize) topics: \(topics)")
    }
    chmgr.checkAllTopicConsistency("gamescreen on appear")
  }
  
  func onCantStartNewGameAction() {
    print("//GameScreen onCantStartNewGameAction")
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
    chmgr.checkAllTopicConsistency("on start game")
    return ok
  }
  func endGame(status:StateOfPlay){
    chmgr.checkAllTopicConsistency("end game")
    gs.teardownAfterGame(state: status, chmgr: chmgr)
  }

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
    ForEach([8], id: \.self) { s in
      GameScreen(
        gs:GameState(size:8, topics:["Fun"],
                     challenges: [Challenge.complexMock]),
        chmgr: ChaMan(playData: PlayData.mock),
        topics: .constant(["Actors", "Animals", "Cars"]), size:.constant(s),
        onSingleTap: { row,col in
          print("Tapped cell with challenge \(row) \(col)")
          return false
        }
      )
      //.previewLayout(.fixed(width: 300, height: 300))
      .previewDisplayName("Size \(s)x\(s)")
    }
  }
}



