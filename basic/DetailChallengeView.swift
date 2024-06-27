import SwiftUI
// MARK: - Modified GameBoard Class
@Observable
class GameBoard : ObservableObject,Codable {
  var board: [[Challenge]]  // these are copied in for each new game from the ChallengeManager
  var cellstate: [[ChallengeOutcomes]]
  var size: Int
  var topics: [String]
  var gimmees: Int
  
  enum CodingKeys: String, CodingKey {
    case _board = "board"
    case _cellstate = "cellstate"
    case _topics = "topics"
    case _size = "selected"
    case _gimmees = "gimmees"
  }
  init(size: Int, topics: [String], challenges: [Challenge]) {
    self.size = size
    self.topics = topics
    self.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: size), count: size)
    self.cellstate = Array(repeating: Array(repeating: .unplayed, count: size), count: size)
    self.gimmees = 0 
    populateBoard(with: challenges)
  }
  func saveGameBoard( ) {
      let filePath = getGameBoardFilePath()
      do {
          let data = try JSONEncoder().encode(self)
          try data.write(to: filePath)
      } catch {
          print("Failed to save gameboard: \(error)")
      }
  }
  // Load the GameBoard
 func loadGameBoard() -> GameBoard? {
      let filePath = getGameBoardFilePath()
      do {
          let data = try Data(contentsOf: filePath)
          let gb = try JSONDecoder().decode(GameBoard.self, from: data)
          return gb
      } catch {
          print("Failed to load gameboard: \(error)")
          return nil
      }
  }
}
struct Challenge: Codable, Equatable, Hashable, Identifiable {
    public init(question: String, topic: String, hint: String, answers: [String], correct: String, explanation: String? = nil, id: String, date: Date, aisource: String, notes: String? = nil) {
        self.question = question
        self.topic = topic
        self.hint = hint
        self.answers = answers
        self.correct = correct
        self.explanation = explanation
        self.id = id
        self.date = date
        self.aisource = aisource
        self.notes = notes
    }
    
    public let question: String
    public let topic: String
    public let hint: String
    public let answers: [String]
    public let correct: String
    public let explanation: String?
    public let id: String
    public let date: Date
    public let aisource: String
    public let notes: String?
}

extension Challenge {
    static let mock = Challenge(question: "For Madmen Only", topic: "Animals", hint: "long time ago", answers: ["most", "any", "old", "song"], correct: "old", id: "UUID320239", date: Date.now, aisource: "donner's brain")
}

enum ChallengeOutcomes : Codable {
    case playedCorrectly, playedIncorrectly, unplayed
}

extension ChallengeOutcomes {
    var borderColor: Color {
        switch self {
        case .playedCorrectly: return .green
        case .playedIncorrectly: return .red
        case .unplayed: return .gray
        }
    }
}
#Preview {
    DetailChallengeView(row: 0, col: 0, playCount: .constant(31))
        .environmentObject(AppColors())
        .environmentObject(GameBoard(size: 1, topics: ["Fun"], challenges: [Challenge.mock]))
}
struct DetailChallengeView: View {
    let row: Int
    let col: Int
    
    @Binding var playCount: Int
    @EnvironmentObject var appColors: AppColors
    @EnvironmentObject var gb: GameBoard
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedAnswer: String? = nil
    @State private var answerCorrect: Bool? = nil
    
    var body: some View {
        let ch: Challenge = gb.board[row][col]
        let state: ChallengeOutcomes = gb.cellstate[row][col]
        
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    // Action for Pass/Ignore
                    dismiss()
                }) {
                    Image(systemName: "nosign")
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(ch.topic)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // Action for Hint
                }) {
                    Image(systemName: "lightbulb")
                        .foregroundColor(Color.yellow)
                        .padding(8)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            Text(ch.question)
                .font(.title2)
                .padding(.horizontal)
                .padding(.top, 5)
            
            // Middle answer buttons arranged in a matrix
            VStack(spacing: 10) {
                ForEach(Array(ch.answers.chunked(into: 2)), id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { answer in
                            Button(action: {
                                selectedAnswer = answer
                                answerCorrect = (answer == ch.correct)
                            }) {
                                Text(answer)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(selectedAnswer == answer ? (answerCorrect == true ? Color.green : Color.red) : Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Yellow area extended almost to the bottom buttons
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow)
                .frame(height: 20)
                .padding(.horizontal)
                .padding(.bottom, 10)
            
            HStack(spacing: 10) {
                Button(action: {
                    gb.cellstate[row][col] = .playedCorrectly
                    playCount += 1
                    dismiss()
                }) {
                    Image(systemName: "checkmark.circle")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                .background(Color.green)
                .cornerRadius(10)
                
                Button(action: {
                    gb.cellstate[row][col] = .playedIncorrectly
                    playCount += 1
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                .background(Color.red)
                .cornerRadius(10)
                
                Button(action: {
                    playCount += 1
                    dismiss()
                }) {
                    Image(systemName: "hands.clap")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                .background(Color.purple)
                .cornerRadius(10)
                
                Button(action: {
                    playCount += 1
                    dismiss()
                }) {
                    Image(systemName: "hands.sparkles")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                .background(Color.purple)
                .cornerRadius(10)
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "nosign")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                .background(Color.gray)
                .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
}

extension Array {
    /// Chunks the array into arrays with a maximum size
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

struct AnswerButtonStyle: ButtonStyle {
    var isSelected: Bool
    var isCorrect: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .frame(width: 60, height: 60)
            .background(isSelected ? (isCorrect ? Color.green : Color.red) : Color.blue)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.blue, lineWidth: 5)
            )
    }
}
