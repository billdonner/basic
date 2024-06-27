import SwiftUI

@Observable
class GameBoard : ObservableObject, Codable {
  var board: [[Challenge]]  // Array of arrays to represent the game board with challenges
  var cellstate: [[ChallengeOutcomes]]  // Array of arrays to represent the state of each cell
  var size: Int  // Size of the game board
  var topics: [String]  // List of topics for the game
  var gimmees: Int  // Number of "gimmee" actions available
  
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
}

struct Challenge: Codable, Equatable, Hashable, Identifiable {
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
}

extension Challenge {
  static let amock = Challenge(
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

enum ChallengeOutcomes: Codable {
  case playedCorrectly, playedIncorrectly, unplayed
  
  var borderColor: Color {
    switch self {
    case .playedCorrectly: return .green
    case .playedIncorrectly: return .red
    case .unplayed: return .gray
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

// More complex mock about KellyAnne Conway
extension Challenge {
  static let complexMock = Challenge(
    question: "What controversial statement did Kellyanne Conway make regarding 'alternative facts' during her tenure as Counselor to the President?",
    topic: "Political History",
    hint: "This statement was made in defense of false claims about the crowd size at the 2017 Presidential Inauguration.",
    answers: ["She claimed it was a joke.", "She denied making the statement.", "She referred to it as 'alternative facts'.", "She blamed the media for misquoting her."],
    correct: "She referred to it as 'alternative facts'.",
    explanation: "Kellyanne Conway used the term 'alternative facts' during a Meet the Press interview on January 22, 2017, to defend White House Press Secretary Sean Spicer's false statements about the crowd size at Donald Trump's inauguration. This phrase quickly became infamous and was widely criticized.",
    id: "UUID123456-ComplexMock",
    date: Date.now,
    aisource: "Historical Documentation",
    notes: "This question addresses a notable moment in modern political discourse and examines the concept of truth in media and politics."
  )
}

#Preview  {
  
  DetailChallengeView(row: 0,col:0,playCount: .constant(32))
    .environment(AppColors())
    .environment(GameBoard(size:3,topics:["Animals"], challenges: [Challenge.complexMock]))
}

import SwiftUI
import SwiftUI

struct DetailChallengeView: View {
    let row: Int
    let col: Int
    
    @Binding var playCount: Int  // Binding to track play count
    @EnvironmentObject var appColors: AppColors  // Environment object for app colors
    @EnvironmentObject var gb: GameBoard  // Environment object for game board
    @Environment(\.dismiss) var dismiss  // Environment value for dismissing the view
    
    @State private var selectedAnswer: String? = nil  // State to track selected answer
    @State private var answerCorrect: Bool? = nil  // State to track if the selected answer is correct
    @State private var showHint: Bool = false  // State to show/hide hint
    @State private var answerGiven: Bool = false  // State to prevent further interactions after an answer is given
    @State private var timer: Timer? = nil  // Timer to track elapsed time
    @State private var elapsedTime: TimeInterval = 0  // Elapsed time in seconds
    @State private var showCorrectAnswer: Bool = false  // State to show correct answer temporarily
    @State private var animateBackToBlue: Bool = false  // State to animate answers back to blue
    @State private var showBorders: Bool = false  // State to show borders after animation

    var body: some View {
        GeometryReader { geometry in
            VStack {
                TopBarView(
                    topic: gb.board[row][col].topic,
                    elapsedTime: formattedElapsedTime, additionalInfo:"Scores will go here",
                    handlePass: handlePass,
                    toggleHint: toggleHint
                )
                questionAndAnswersSection(geometry: geometry)
                Spacer()
                yellowArea(geometry: geometry)
                bottomButtons
            }
        
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.horizontal, 10)
            .padding(.bottom, 30)
            .frame(width: geometry.size.width ) // Center the content with padding
            .onAppear(perform: startTimer)
            .onDisappear(perform: stopTimer)
        }
    }

    func questionAndAnswersSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 15) {
            questionSection(geometry: geometry)
            answerButtonsView(geometry: geometry)
        }
        .padding(.horizontal)
        .padding(.vertical)
    }

    func questionSection(geometry: GeometryProxy) -> some View {
        let paddingWidth = geometry.size.width * 0.1
        let contentWidth = geometry.size.width - paddingWidth
        let topicColor = appColors.colorFor(topic: gb.board[row][col].topic)?.backgroundColor ?? Color.gray
        
        return Text(gb.board[row][col].question)
            .font(.headline)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(topicColor.opacity(0.2))) // Use topic color for background
            .frame(width: contentWidth, height: geometry.size.height * 0.2)
            .lineLimit(8)
            .fixedSize(horizontal: false, vertical: true) // Ensure the text box grows vertically
    }

    func answerButtonsView(geometry: GeometryProxy) -> some View {
        let answers = gb.board[row][col].answers
        let paddingWidth = geometry.size.width * 0.1
        let contentWidth = geometry.size.width - paddingWidth
        
        if answers.count >= 5 {
            let buttonWidth = (contentWidth / 2.5) - 10 // Adjust width to fit 2.5 buttons
            let buttonHeight = buttonWidth * 1.57 // 57% higher than the four-answer case
            return AnyView(
                VStack {
                    ScrollView(.horizontal) {
                        HStack(spacing: 15) {
                            ForEach(answers, id: \.self) { answer in
                                answerButton(answer: answer, buttonWidth: buttonWidth, buttonHeight: buttonHeight, taller: true)
                            }
                        }
                        .padding(.horizontal)
                        .disabled(answerGiven)  // Disable all answer buttons after an answer is given
                    }
                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }
                .frame(width: contentWidth) // Set width of the scrolling area
            )
        } else if answers.count == 3 {
            return AnyView(
                VStack(spacing: 15) {
                    answerButton(answer: answers[0], buttonWidth: contentWidth / 2)
                    HStack {
                        answerButton(answer: answers[1], buttonWidth: contentWidth / 2.5)
                        answerButton(answer: answers[2], buttonWidth: contentWidth / 2.5)
                    }
                }
                .padding(.horizontal)
                .disabled(answerGiven)  // Disable all answer buttons after an answer is given
            )
        } else {
            let buttonWidth = min(geometry.size.width / 3 - 20, 100) * 1.5
            let buttonHeight = buttonWidth * 0.8 // Adjust height to fit more lines
            return AnyView(
                VStack(spacing: 15) {
                    ForEach(answers.chunked(into: 2), id: \.self) { row in
                        HStack {
                            ForEach(row, id: \.self) { answer in
                                answerButton(answer: answer, buttonWidth: buttonWidth, buttonHeight: buttonHeight)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .disabled(answerGiven)  // Disable all answer buttons after an answer is given
            )
        }
    }

    func answerButton(answer: String, buttonWidth: CGFloat, buttonHeight: CGFloat? = nil, taller: Bool = false) -> some View {
        Button(action: {
            handleAnswerSelection(answer: answer)
        }) {
            Text(answer)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .frame(width: buttonWidth, height: buttonHeight)
                .background(
                    Group {
                        if answerGiven {
                            if answer == selectedAnswer {
                                answerCorrect == true ? Color.green : Color.red
                            } else if answerCorrect == true {
                                Color.red
                            } else if showCorrectAnswer && answer == gb.board[row][col].correct {
                                Color.green
                            } else if animateBackToBlue {
                                Color.blue
                            } else {
                                Color.blue
                            }
                        } else {
                            Color.blue
                        }
                    }
                )
                .cornerRadius(15)  // Make the buttons rounded rectangles
                .minimumScaleFactor(0.5)  // Adjust font size to fit
                .lineLimit(8)
                .rotationEffect(showCorrectAnswer && answer == gb.board[row][col].correct ? .degrees(360) : .degrees(0))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)  // Match the corner radius
                        .stroke(showBorders && answer == selectedAnswer && !answerCorrect! ? Color.red : showBorders && answer == gb.board[row][col].correct && answerCorrect == false ? Color.green : Color.clear, lineWidth: 5)
                )
                .animation(.easeInOut(duration: showCorrectAnswer ? 1.0 : 0.5), value: showCorrectAnswer)
                .animation(.easeInOut(duration: answerGiven ? 1.0 : 0.5), value: animateBackToBlue)
                .animation(.easeInOut(duration: 0.5), value: showBorders)
        }
    }

    func yellowArea(geometry: GeometryProxy) -> some View {
        let paddingWidth = geometry.size.width * 0.1
        let contentWidth = geometry.size.width - paddingWidth

        return VStack {
            if showHint {
                Text(gb.board[row][col].hint)
                    .font(.headline)
                    .foregroundColor(.black)
            } else if let answerCorrect = answerCorrect {
                Text(answerCorrect ? "Correct" : "Incorrect")
                    .font(.headline)
                    .foregroundColor(.black)
            } else {
                Text("")
            }
            if let explanation = gb.board[row][col].explanation, answerGiven {
                ScrollView {
                    Text(explanation)
                        .font(.caption)
                        .padding(.top, 5)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).fill(
                showHint || (answerCorrect != nil) || (answerGiven && gb.board[row][col].explanation != nil) ? Color.yellow : Color.clear
            )
        )
        .frame(width: contentWidth, height: geometry.size.height * 0.15)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .center)
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
        .frame(height: 60)
    }

    var passButton: some View {
        Button(action: {
            handlePass()
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
            toggleHint()
        }) {
            Image(systemName: "lightbulb")
                .foregroundColor(Color.yellow)
                .padding(8)
                .background(Color.orange)
                .clipShape(Circle())
                .frame(width: 50, height: 50)
        }
    }

    var markCorrectButton: some View {
        Button(action: {
            markAnswerCorrect()
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
            markAnswerIncorrect()
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
            handleGimmee()
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
            handleGimmeeAll()
        }) {
            Image(systemName: "rectangle.stack.person.crop.fill")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }

    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startTimer() {
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension DetailChallengeView {
    func handleAnswerSelection(answer: String) {
        selectedAnswer = answer
        answerCorrect = (answer == gb.board[row][col].correct)
        answerGiven = true

        if answerCorrect == false {
            showCorrectAnswer = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showCorrectAnswer = false
                showBorders = true
            }
        } else {
            animateBackToBlue = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                animateBackToBlue = false
                showBorders = true
            }
        }

        stopTimer()
    }

    func handlePass() {
        dismiss()
        stopTimer()
    }

    func toggleHint() {
        showHint.toggle()
    }

    func markAnswerCorrect() {
        selectedAnswer = gb.board[row][col].correct
        answerCorrect = true
        answerGiven = true
        animateBackToBlue = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            animateBackToBlue = false
            showBorders = true
        }
        stopTimer()
    }

    func markAnswerIncorrect() {
        if let sel = selectedAnswer, sel != gb.board[row][col].correct {
            answerCorrect = false
            answerGiven = true
            showCorrectAnswer = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showCorrectAnswer = false
                showBorders = true
            }
            stopTimer()
        }
    }

    func handleGimmee() {
        playCount += 1
        dismiss()
        stopTimer()
    }

    func handleGimmeeAll() {
        playCount += 1
        dismiss()
        stopTimer()
    }
}


extension Challenge {
  static let complexMockWithFiveAnswers = Challenge(
    question: "Which of the following statements about Abraham Lincoln is NOT true?",
    topic: "American History",
    hint: "This statement involves a significant policy change during Lincoln's presidency.",
    answers: [
      "Abraham Lincoln issued the Emancipation Proclamation in 1863.",
      "Lincoln delivered the Gettysburg Address in 1863.",
      "Abraham Lincoln was the first U.S. president to be assassinated.",
      "Lincoln signed the Homestead Act in 1862.",
      "Lincoln served two terms as President of the United States."
    ],
    correct: "Lincoln served two terms as President of the United States.",
    explanation: """
        Abraham Lincoln did not serve two full terms as President. He was re-elected in 1864 but was assassinated by John Wilkes Booth on April 14, 1865, just a little over a month into his second term. Lincoln's first term was from March 4, 1861, to March 4, 1865, and he was re-elected for a second term in March 1865. He issued the Emancipation Proclamation on January 1, 1863, delivered the Gettysburg Address on November 19, 1863, and signed the Homestead Act into law on May 20, 1862.
        """,
    id: "UUID123456-ComplexMockWithFiveAnswers",
    date: Date.now,
    aisource: "Historical Documentation",
    notes: "This question tests detailed knowledge of key events and facts about Abraham Lincoln's presidency."
  )
}

extension Challenge {
  static let complexMockWithThreeAnswers = Challenge(
    question: "In the context of quantum mechanics, which of the following interpretations suggests that every possible outcome of a quantum event exists in its own separate universe?",
    topic: "Quantum Mechanics",
    hint: "This interpretation was proposed by Hugh Everett in 1957.",
    answers: ["Copenhagen Interpretation", "Many-Worlds Interpretation", "Pilot-Wave Theory"],
    correct: "Many-Worlds Interpretation",
    explanation: "The Many-Worlds Interpretation, proposed by Hugh Everett, suggests that all possible alternate histories and futures are real, each representing an actual 'world' or 'universe'. This means that every possible outcome of every event defines or exists in its own 'world'.",
    id: "UUID123456-ComplexMockWithThreeAnswers",
    date: Date.now,
    aisource: "Advanced Quantum Theory",
    notes: "This question delves into interpretations of quantum mechanics, particularly the philosophical implications of quantum events and their outcomes."
  )
}

#Preview {
  DetailChallengeView(row: 0, col: 0, playCount: .constant(31))
    .environmentObject(AppColors())
    .environmentObject(GameBoard(size: 1, topics: ["Programming Languages"], challenges: [Challenge.complexMockWithFiveAnswers]))
}
#Preview {
  DetailChallengeView(row: 0, col: 0, playCount: .constant(31))
    .environmentObject(AppColors())
    .environmentObject(GameBoard(size: 1, topics: ["Quantum Mechanics"], challenges: [Challenge.complexMockWithThreeAnswers]))
}
