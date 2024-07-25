import SwiftUI



struct ContentView:View {
  @State var restartCount = 0
  internal init(gs: GameState, chaMan: ChaMan, current_size: Int = starting_size, current_topics: [String] = [], chal: IdentifiablePoint? = nil, isPresentingDetailView: Bool = false) {

    self.gs = gs
    self.chaMan = chaMan
    self.current_size = current_size
    self.current_topics = current_topics
    self.chal = chal
    self.isPresentingDetailView = isPresentingDetailView
    // on restart force them to start a new game if one is in progress
//    if gs.gamestate == .playingNow {
//      gs.teardownAfterGame(state: .justAbandoned, chmgr: chaMan)
//    }
    restartCount += 1
  }
  
@Bindable var gs: GameState
  @Bindable var chaMan: ChaMan
  @State var current_size: Int = starting_size
  @State var current_topics: [String] = []
  @State var chal : IdentifiablePoint? = nil
  @State var isPresentingDetailView =  false
  var body: some View {
    GameScreen(gs:gs,
               chmgr:chaMan, topics: $current_topics, size:$current_size )
    { row,col    in
      //tap behavior
      isPresentingDetailView = true
      chal = IdentifiablePoint(row:row,col:col)
      return false
    }
    .onAppear {
      if gs.veryfirstgame {
        chaMan.loadAllData(gs:gs)
        current_size = gs.boardsize
        if gs.topicsinplay.count == 0 {
          gs.topicsinplay = getRandomTopics(GameState.preselectedTopicsForBoardSize(current_size), from: chaMan.everyTopicName) //*****1
        }
        current_topics = gs.topicsinplay
        chaMan.checkTopicConsistency("ContentView onAppear")
        print("//ContentView first onAppear size:\(current_size) topics:\(current_topics) restartcount \(restartCount)")
        //chaMan.dumpTopics()
      } else {


        print("//ContentView onAppear restart size:\(current_size) topics:\(current_topics) restartcount \(restartCount)")
      }
      restartCount += 1
      gs.veryfirstgame = false
    }
    .onDisappear {
      print("Yikes the ContentView is Disappearing!")
      }

    .sheet(item:$chal ) { cha in
      QandAScreen (row:cha.row,col:cha.col,  isPresentingDetailView: $isPresentingDetailView,chmgr: chaMan, gs: gs)
    }
  }
}

#Preview {
  ContentView(gs: GameState(size: 3, topics:Array(MockTopics.mockTopics.prefix(7)), challenges: Challenge.mockChallenges), chaMan: ChaMan(playData: PlayData.mock))
}
