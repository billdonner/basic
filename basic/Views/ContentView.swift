import SwiftUI

// Assuming a mock PlayData JSON file in the main bundle
let jsonFileName = "playdata.json"
let starting_size = 3 // Example size, can be 3 to 6
let starting_topics = ["Actors", "Animals","Cars"] // Example topics

struct ContentView:View {
  @EnvironmentObject var challengeManager: ChallengeManager
  @EnvironmentObject var gameBoard: GameBoard
  @State var chal :IdentifiablePoint? = nil

  @State var isPresentingDetailView =  false
  var body: some View {
    GameScreen(size: starting_size, topics: starting_topics){ row,col    in
      //tap behavior
      isPresentingDetailView = true 
      chal = IdentifiablePoint(row:row,col:col)
    }
    .onAppear {
      loadAllData(challengeManager: challengeManager,gameBoard:gameBoard)
      }
      .onDisappear {
        saveChallengeStatuses(challengeManager.challengeStatuses)
      }
      .sheet(item:$chal ) { cha in
        QandAScreen (row:cha.row,col:cha.col,  isPresentingDetailView: $isPresentingDetailView)
          .environmentObject(challengeManager)
        }
      }
  }
func loadAllData (challengeManager: ChallengeManager,gameBoard:GameBoard) {
  do {
    if  let gb =  gameBoard.loadGameBoard() {
      gameBoard.cellstate = gb.cellstate
      gameBoard.size = gb.size
      gameBoard.topics = gb.topics
      gameBoard.board = gb.board
      gameBoard.gimmees = gb.gimmees
      gameBoard.playcount = gb.playcount
    }
    try challengeManager.playData = loadPlayData(from: jsonFileName)
    if let playData = challengeManager.playData {
      if let loadedStatuses = loadChallengeStatuses() {
        challengeManager.challengeStatuses = loadedStatuses
      } else {
        let challenges = playData.gameDatum.flatMap { $0.challenges}
        var cs:[ChallengeStatus] = []
        for j in 0..<challenges.count {
          cs.append(ChallengeStatus(id:challenges[j].id,val:.inReserve))
        }
        challengeManager.challengeStatuses = cs
      }
    }
  } catch {
    print("Failed to load PlayData: \(error)")
  }
}

#Preview {
  ContentView().environmentObject(ChallengeManager())  .environmentObject(GameBoard(size: 5, topics: ["A","B","C"], challenges:[Challenge.complexMock]))
}
