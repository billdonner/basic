import SwiftUI

// Assuming a mock PlayData JSON file in the main bundle
let jsonFileName = "playdata.json"
let starting_size = 3 // Example size, can be 3 to 6
let starting_topics = ["Actors", "Animals","Cars"] // Example topics

struct ContentView:View {
  @EnvironmentObject var challengeManager: ChallengeManager
  @EnvironmentObject var gameBoard: GameBoard
  @State var current_size: Int = starting_size
  @State var current_topics: [String] = starting_topics
  @State var chal :IdentifiablePoint? = nil
  @State var isPresentingDetailView =  false
  var body: some View {
    GameScreen(size: current_size, topics: current_topics)
    { row,col    in
      //tap behavior
      isPresentingDetailView = true 
      chal = IdentifiablePoint(row:row,col:col)
    }
    .onAppear {
      print("//ContentView onAppear")
      challengeManager.loadAllData(gameBoard:gameBoard)
      }
      .onDisappear {
        print("//ContentView onDisappear")
        challengeManager.saveChallengeStatus()
        gameBoard.saveGameBoard()
      }
      .sheet(item:$chal ) { cha in
        QandAScreen (row:cha.row,col:cha.col,  isPresentingDetailView: $isPresentingDetailView,challengeManager: challengeManager) 
        }
      }
  }


#Preview {
  ContentView().environmentObject(ChallengeManager(playData: PlayData.mock))
    .environmentObject(GameBoard(size: 5, topics: ["A","B","C"], challenges:[Challenge.complexMock]))
}
