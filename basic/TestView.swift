//
//  TestView.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//
import SwiftUI

struct TestView: View {
    let size: Int
    let topics: [String]
    let tapGesture: (_ row: Int, _ col: Int) -> Void
    @EnvironmentObject var appColors: AppColors
    @EnvironmentObject var challengeManager: ChallengeManager
    @State private var gameBoard: GameBoard?
  

    @State private var hideCellContent = true
    private let spacing: CGFloat = 5
    // Adding a shrink factor to slightly reduce the cell size
    private let shrinkFactor: CGFloat = 0.9
    
    fileprivate func makeOneCell(_ row: Int, _ col: Int, gameBoard: GameBoard, cellSize: CGFloat) -> some View {
      let challenge = gameBoard.board[row][col]
      let colormix = AppColors.colorFor(topic: challenge.topic)
        return VStack {
            Text(hideCellContent ? " " : challenge.question)
                .padding(8)
                .frame(width: cellSize, height: cellSize)
                .background(colormix?.backgroundColor)
                .foregroundColor(colormix?.foregroundColor)
                .border(borderColor(for: gameBoard.status[row][col]), width: 24/cellSize)
                .cornerRadius(8)
                .onTapGesture {
                    tapGesture(row, col)
                }
        }
    }
    
  
  
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                  let ok =   startNewGame(size: size, topics: topics)
                    hideCellContent = false
                  if !ok {
                    // ALERT HERE and possible reset
                  }
                }) {
                    Text("Start Game")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!hideCellContent)
                .opacity(hideCellContent ? 1 : 0.5)
                
                Button(action: {
                    endGame()
                    hideCellContent = true
                }) {
                    Text("End Game")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(hideCellContent)
                .opacity(!hideCellContent ? 1 : 0.5)
                
                Button(action: {
                    challengeManager.resetAllChallengeStatuses()
                    hideCellContent = true
                    clearAllCells()
                }) {
                    Text("Full Reset")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!hideCellContent)
                .opacity(hideCellContent ? 1 : 0.5)
            }
            .padding()
            
            if let gameBoard = gameBoard {
                GeometryReader { geometry in
                    let totalSpacing = spacing * CGFloat(gameBoard.size - 1)
                    let axisSize = min(geometry.size.width, geometry.size.height) - totalSpacing
                    let cellSize = (axisSize / CGFloat(gameBoard.size)) * shrinkFactor  // Apply shrink factor
                    
//                    ScrollView([.horizontal, .vertical]) {
                  VStack(alignment:.center, spacing: spacing) {
                            ForEach(0..<gameBoard.size, id: \.self) { row in
                                HStack(spacing: spacing) {
                                    ForEach(0..<gameBoard.size, id: \.self) { col in
                                        makeOneCell(row, col, gameBoard: gameBoard, cellSize: cellSize)
                                    }
                                }
                            }
                        }
                    .padding()
              }
            } else {
                Text("Loading...")
                    .onAppear {
                      let ok =   startNewGame(size: size, topics: topics)
                      if !ok  {
                        // first game cant load
                        
                      }
                    }
            }
            Spacer()
            Divider()
            VStack {
                HStack {
                    Text("Allocated: \(allocatedChallengesCount())")
                    Text("Free: \(freeChallengesCount())")
                    // Text("PlayingNow: \(playingNow)")
                }
                AllocatorView()
              
                
            }.frame(height: 150)
            
        }
    }
    
    func startNewGame(size: Int, topics: [String]) -> Bool {
        if let challenges = challengeManager.allocateChallenges(forTopics: topics, count: size * size) {
            gameBoard = GameBoard(size: size, topics: topics, challenges: challenges)
            randomlyMarkCells()
          return true
        } else {
          print("Failed to allocate \(size) challenges for topic \(topics.joined(separator: ","))")
          print("Consider changing the topics in setting...")
        }
      return false
    }
    
    func endGame() {
        if let gameBoard = gameBoard {
            let unplayedChallenges = gameBoard.resetBoard()
            challengeManager.resetChallengeStatuses(at: unplayedChallenges.map { challengeManager.getAllChallenges().firstIndex(of: $0)! })
        }
    }
    
    func clearAllCells() {
        guard let gameBoard = gameBoard else { return }
        for row in 0..<gameBoard.size {
            for col in 0..<gameBoard.size {
                gameBoard.status[row][col] = .inReserve
            }
        }
    }
    
    func randomlyMarkCells() {
        guard let gameBoard = gameBoard else { return }
        let totalCells = gameBoard.size * gameBoard.size
        let correctCount = totalCells / 3
        let incorrectCount = totalCells / 2
        
        var correctMarked = 0
        var incorrectMarked = 0
        
        for row in 0..<gameBoard.size {
            for col in 0..<gameBoard.size {
                if correctMarked < correctCount {
                    gameBoard.status[row][col] = .playedCorrectly
                    correctMarked += 1
                } else if incorrectMarked < incorrectCount {
                    gameBoard.status[row][col] = .playedIncorrectly
                    incorrectMarked += 1
                } else {
                    gameBoard.status[row][col] = .allocated
                }
            }
        }
    }
    
    func borderColor(for status: ChallengeStatus) -> Color {
        switch status {
        case .playedCorrectly:
            return .green
        case .playedIncorrectly:
            return .red
        default:
            return .clear
        }
    }
    
    func allocatedChallengesCount() -> Int {
        return challengeManager.challengeStatuses.filter { $0 == .allocated }.count
    }
    
    func freeChallengesCount() -> Int {
        return challengeManager.challengeStatuses.filter { $0 == .inReserve }.count
    }
}

// Preview Provider for SwiftUI preview
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach([3, 4, 5, 6], id: \.self) { size in
                TestView(
                    size: size,
                    topics: ["Actors", "Animals", "Cars"],
                    tapGesture: { row, col in
                        print("Tapped cell at row \(row), col \(col)")
                    }
                )
                .environmentObject(ChallengeManager())  // Ensure to add your ChallengeManager
                .previewLayout(.fixed(width: 300, height: 300))
                .previewDisplayName("Size \(size)x\(size)")
            }
        }
    }
}

