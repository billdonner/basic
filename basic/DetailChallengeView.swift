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
    static let mock = Challenge(
        question: "What is the capital of the fictional land where dragons and wizards are commonplace?",
        topic: "Fantasy Geography",
        hint: "This land is featured in many epic tales, often depicted with castles and magical forests.",
        answers: ["Eldoria", "Mysticore", "Dragontown", "Wizardville"],
        correct: "Mysticore",
        explanation: "Mysticore is the capital of the mystical realm in the series 'Chronicles of the Enchanted Lands', known for its grand castle surrounded by floating islands.",
        id: "UUID320239-MoreComplex",
        date: Date.now,
        aisource: "Advanced AI Conjecture",
        notes: "This question tests knowledge of fictional geography and is intended for advanced level quiz participants in the fantasy genre."
    )
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
#Preview {
    DetailChallengeView(row: 0, col: 0, playCount: .constant(31))
        .environmentObject(AppColors())
        .environmentObject(GameBoard(size: 1, topics: ["Fun"], challenges: [Challenge.mock]))
}
import SwiftUI

struct DetailChallengeView: View {
    let row: Int
    let col: Int
    
    @Binding var playCount: Int
    @EnvironmentObject var appColors: AppColors
    @EnvironmentObject var gb: GameBoard
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedAnswer: String? = nil
    @State private var answerCorrect: Bool? = nil
    @State private var showHint: Bool = false
    @State private var answerGiven: Bool = false  // State to prevent further interactions after an answer is given

    var body: some View {
        GeometryReader { geometry in
            VStack {
                topBar
                questionSection
                answerButtonsView(geometry: geometry)
                if showHint {
                    hintArea(geometry: geometry)
                } else {
                    yellowArea(geometry: geometry)
                }
                Spacer() // Ensures bottom buttons stay at the bottom
                bottomButtons
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.horizontal)  // Ensure uniform padding
        }
    }

    var topBar: some View {
        HStack {
            passButton
            Spacer()
            Text(gb.board[row][col].topic)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            hintButton
        }
        .padding(.horizontal)
        .padding(.top)
    }

    var questionSection: some View {
        Text(gb.board[row][col].question)
            .font(.title2)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.5))) // Light background
            .padding(.horizontal)
    }

    func answerButtonsView(geometry: GeometryProxy) -> some View {
        let buttonWidth = min(geometry.size.width / 3 - 20, 80) * 1.3 // Increased size
        return VStack(spacing: 15) {
            ForEach(gb.board[row][col].answers.chunked(into: 2), id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { answer in
                        answerButton(answer: answer, buttonWidth: buttonWidth)
                    }
                }
            }
        }
        .padding(.horizontal)
        .disabled(answerGiven)  // Disable all answer buttons after an answer is given
    }

    func answerButton(answer: String, buttonWidth: CGFloat) -> some View {
        Button(action: {
            selectedAnswer = answer
            answerCorrect = (answer == gb.board[row][col].correct)
            answerGiven = true  // Prevent further interactions after an answer is given
        }) {
            Text(answer)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .frame(width: buttonWidth, height: buttonWidth)
                .background(selectedAnswer == answer ? (answerCorrect == true ? Color.green : Color.red) : Color.blue)
                .cornerRadius(10)
        }
    }

    func yellowArea(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.yellow)
            .frame(height: geometry.size.height * 0.1) // 10% of total height for the yellow area
            .padding(.horizontal)
    }
    
    func hintArea(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.yellow)
            .overlay(
                Text(gb.board[row][col].hint)
                    .font(.caption)
                    .padding()
                    .foregroundColor(.black)
            )
            .frame(height: geometry.size.height * 0.2) // Make the hint area larger
            .padding(.horizontal)
    }

    var bottomButtons: some View {
        HStack(spacing: 10) {
            passButton
            markCorrectButton
            markIncorrectButton
            gimmeeButton
            gimmeeAllButton  // New button for "Gimmee All"
        }
        .padding(.bottom)
    }

    var passButton: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "nosign")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.gray)
                .cornerRadius(10)
        }
    }

    var hintButton: some View {
        Button(action: {
            showHint.toggle()
        }) {
            Image(systemName: "lightbulb")
                .foregroundColor(Color.yellow)
                .padding(8)
                .background(Color.orange)
                .clipShape(Circle())
        }
    }

    var markCorrectButton: some View {
        Button(action: {
            selectedAnswer = gb.board[row][col].correct
            answerCorrect = true
            answerGiven = true
        }) {
            Image(systemName: "checkmark.circle")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.green)
                .cornerRadius(10)
        }
    }

    var markIncorrectButton: some View {
        Button(action: {
            if let sel = selectedAnswer, sel != gb.board[row][col].correct {
                answerCorrect = false
                answerGiven = true
            }
        }) {
            Image(systemName: "xmark.circle")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.red)
                .cornerRadius(10)
        }
    }

    var gimmeeButton: some View {
        Button(action: {
            playCount += 1
            dismiss()
        }) {
            Image(systemName: "hands.clap")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.purple)
                .cornerRadius(10)
        }
    }

    var gimmeeAllButton: some View {
        Button(action: {
            playCount += 1
            dismiss()
        }) {
            Image(systemName: "rectangle.stack.person.crop.fill")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
        }
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
