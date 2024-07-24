import SwiftUI

let playDataFileName = "playdata.json"
let starting_size = 6 // Example size, can be 3 to 6

struct ContentView:View {
@Bindable var gs: GameState
  @Bindable var chaMan: ChaMan
  
  @State var current_size: Int = starting_size
  @State var current_topics: [String] = []//Array(MockTopics.mockTopics[0..<starting_size])
  @State var chal : IdentifiablePoint? = nil
  @State var isPresentingDetailView =  false
  var body: some View {
    GameScreen(gs:gs,
               chmgr:chaMan, topics: $current_topics, size:$current_size )
    { row,col    in
      //tap behavior
      isPresentingDetailView = true
      chal = IdentifiablePoint(row:row,col:col)
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
        print("//ContentView first onAppear size:\(current_size) topics:\(current_topics)")
        //chaMan.dumpTopics()
      } else {
        print("//ContentView onAppear size:\(current_size) topics:\(current_topics)")
      }
      
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
