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
  @Binding  var size:Int
  let onSingleTap: (_ row:Int, _ col:Int ) -> Bool
  
  @State   var firstMove = true
  @State   var startAfresh = true
  @State   var showSettings = false
  @State   var showingHelp = false
  @State   var showWinAlert = false
  @State   var showLoseAlert = false
  @State   var showCantStartAlert = false
  
  var bodyMsg: String {
    let t =  """
    That was game \(gs.gamenumber) of which you've won \(gs.woncount) and lost \(gs.lostcount) games
"""
    return t
  }
  
  var body: some View {
    VStack {
      VStack {
        VStack(spacing:10) {
          topButtonsVeew//.frame(height:40)// down below
            .padding()
          ScoreBarView(gs: gs)
        }
        
        if gs.boardsize > 1 {
          VStack(alignment: .center){
            MainGridView(gs: gs, chmgr:chmgr,
                         firstMove: $firstMove, onSingleTap: onSingleTap)//.border(Color.red)
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
        }
        else {
          loadingVeew
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
            chmgr.checkAllTopicConsistency("GameScreen StartGamePressed")
            assert(gs.checkVsChaMan(chmgr: chmgr))
          }
        }) {
          Text("Start Game")
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .font(.body)
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
          withAnimation {
            assert(gs.checkVsChaMan(chmgr: chmgr)) //cant check after endgamepressed
            onEndGamePressed()  //should estore consistency
            chmgr.checkAllTopicConsistency("GameScreen EndGamePressed")
          }
        }) {
          Text("End Game")
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            .font(.body)
        }
      }
      //SETTINGS
      Button(action: {  withAnimation {showSettings = true } } ) {
        Text("Settings")
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
          .font(.body)
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
    }.font(.body).lineLimit(1)
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
//#Preview ("GameScreen") {
//  @Previewable @State var topics: [String] = GameState.mock.topicsinplay
//  Group {
//    ForEach([8], id: \.self) { s in
//      GameScreen(
//        gs:GameState.mock ,
//        chmgr: ChaMan(playData: PlayData.mock),
//        topics:$topics,
//        size:.constant(s),
//        onSingleTap: { row,col in
//          print("Tapped cell with challenge \(row) \(col)")
//          return false
//        }
//      )
//      //.previewLayout(.fixed(width: 300, height: 300))
//      .previewDisplayName("Size \(s)x\(s)")
//    }
//  }
//}



