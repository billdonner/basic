import SwiftUI

let playDataFileName = "playdata.json"
let starting_size = 3 // Example size, can be 3 to 6

struct ContentView:View {
  @State var chaMan = ChaMan(playData: PlayData.mock )
  @State var gameBoard = GameBoard(size: starting_size,
                                         topics: Array(MockTopics.mockTopics.prefix(starting_size)),
                                         challenges:Challenge.mockChallenges)
  
  @State var current_size: Int = starting_size
  @State var current_topics: [String] = Array(MockTopics.mockTopics[0..<starting_size])
  @State var chal : IdentifiablePoint? = nil
  @State var isPresentingDetailView =  false
  var body: some View {
    GameScreen(gameBoard:gameBoard,
               chmgr:chaMan,
               size: $current_size, topics: $current_topics)
    { row,col    in
      //tap behavior
      isPresentingDetailView = true 
      chal = IdentifiablePoint(row:row,col:col)
    }
    .onAppear {
      chaMan.loadAllData(gameBoard:gameBoard)
      current_size = gameBoard.size
      if gameBoard.topicsinplay.count == 0 {
        print("//*****1")
        gameBoard.topicsinplay = getRandomTopics(current_size - 1, from: chaMan.allTopics) //*****1
      }
      current_topics = gameBoard.topicsinplay
      print("//ContentView onAppear size:\(current_size) topics:\(current_topics)")
      }
      .onDisappear {
        print("//ContentView onDisappear size:\(current_size) topics:\(current_topics)")
       chaMan.saveChallengeStatus()
        gameBoard.saveGameBoard()
      }
      .sheet(item:$chal ) { cha in
        QandAScreen (row:cha.row,col:cha.col,  isPresentingDetailView: $isPresentingDetailView,chmgr: chaMan, gb: gameBoard)
        }
      }
  }


#Preview {
  ContentView()
}
