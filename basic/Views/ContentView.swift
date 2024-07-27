import SwiftUI



struct ContentView:View {
  @State var restartCount = 0
  internal init(gs: GameState, chaMan: ChaMan, current_size: Int = starting_size, current_topics: [String] = [], chal: IdentifiablePoint? = nil, 
                isPresentingDetailView: Bool = false) {
    
    self.gs = gs
    self.chmgr = chaMan
    self.current_size = current_size
    self.current_topics = current_topics
    self.chal = chal
    self.isPresentingDetailView = isPresentingDetailView
    
    restartCount += 1
  }
  
  @Bindable var gs: GameState
  @Bindable var chmgr: ChaMan
  @State var current_size: Int = starting_size
  @State var current_topics: [String] = []
  @State var chal : IdentifiablePoint? = nil
  @State var isPresentingDetailView =  false
  
  var body: some View {
    GameScreen(gs:gs, chmgr:chmgr, topics: $current_topics, size:$current_size )
    { row,col    in
      //tap behavior
      isPresentingDetailView = true
      chal = IdentifiablePoint(row:row,col:col,status: chmgr.stati[row*gs.boardsize+col])
      return false
    }
    .onAppear {
      if gs.veryfirstgame {
        chmgr.loadAllData(gs:gs)
        current_size = gs.boardsize
        if gs.topicsinplay.count == 0 {
          gs.topicsinplay = getRandomTopics(GameState.preselectedTopicsForBoardSize(current_size), from: chmgr.everyTopicName) //*****1
        }
        current_topics = gs.topicsinplay
        chmgr.checkTopicConsistency("ContentView onAppear")
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
      QandAScreen (row:cha.row,col:cha.col, st: cha.status, // get status,
                   isPresentingDetailView: $isPresentingDetailView,chmgr: chmgr, gs: gs)
    }
  }
}

#Preview {
  ContentView(gs: GameState(size: 3, topics:Array(MockTopics.mockTopics.prefix(7)), challenges: Challenge.mockChallenges), chaMan: ChaMan(playData: PlayData.mock))
}
