import SwiftUI

struct QandAScreen: View {
  let row: Int
  let col: Int
  @Binding var isPresentingDetailView: Bool
  @Bindable  var chmgr:ChaMan //
  @Bindable var gb: GameBoard  //
  @Environment(\.dismiss) var dismiss  // Environment value for dismissing the view
  
  @State private var selectedAnswer: String? = nil  // State to track selected answer
  @State private var answerCorrect: Bool? = nil  // State to track if the selected answer is correct
  
  @State private var timer: Timer? = nil  // Timer to track elapsed time
  @State private var elapsedTime: TimeInterval = 0  // Elapsed time in seconds
  @State private var showCorrectAnswer: Bool = false  // State to show correct answer temporarily
  
  @State private var showBorders: Bool = false  // State to show borders after animation
  
  @State private var showHint: Bool = false  // State to show/hide hint
  
  @State private var animateBackToBlue: Bool = false  // State to animate answers back to blue
  @State private var dismissToRootFlag = false
  @State private var answerGiven: Bool = false  // State to prevent further interactions after an answer is given
  
  var body: some View {
    GeometryReader { geometry in
      // let _ = print("//QandAScreen Geometry reader \(geometry.size.width)w x \(geometry.size.height)h")
      ZStack {
        VStack {
          QandATopBarView(
            topic: gb.board[row][col].topic, hint: gb.board[row][col].hint,
            elapsedTime:elapsedTime,
            additionalInfo: "Scores will go here",
            handlePass: handlePass,
            toggleHint: toggleHint
          )
          questionAndAnswersSectionVue(geometry: geometry)
          Spacer()
          bottomButtons
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
        // .frame(width: geometry.size.width) // Center the content with padding
        .onAppear {
          print("//QandAScreen onAppear");
          startTimer()
        }
        .onDisappear(perform: {print("//QandAScreen onDisappear");
          stopTimer()})
        
        .hintAlert(isPresented: $showHint, title: "Here's Your Hint", message: gb.board[row][col].hint, buttonTitle: "Dismiss", onButtonTapped: {
          handleDismissal(toRoot:false)
        }, animation: .spring())
        
        .answeredAlert(isPresented: $answerGiven, title: gb.board[row][col].correct, message: gb.board[row][col].explanation ?? "xxx", buttonTitle: "OK", onButtonTapped: {
          handleDismissal(toRoot:true)
        })
      }
    }
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
      Image(systemName: "multiply.circle")
        .font(.title)
        .foregroundColor(.white)
        .frame(width: 50, height: 50)
        .background(Color.gray)
        .cornerRadius(10)
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
  func questionAndAnswersSectionVue(geometry: GeometryProxy) -> some View {
    VStack(spacing: 15) {
      questionSectionVue(geometry: geometry)
      answerButtonsVue(geometry: geometry)
    }
    .padding(.horizontal)
    .padding(.vertical)
    
    .frame(maxWidth: max(0, geometry.size.width), maxHeight: max(0, geometry.size.height * 0.8))
  }
  
  func questionSectionVue(geometry: GeometryProxy) -> some View {
    let paddingWidth = geometry.size.width * 0.1
    let contentWidth = geometry.size.width - paddingWidth
    let topicColor =   colorForTopic(gb.board[row][col].topic,gb:gb).0
    
    return Text(gb.board[row][col].question)
      .font(.headline)
      .padding()
      .background(RoundedRectangle(cornerRadius: 10).fill(topicColor.opacity(0.2))) // Use topic color for background
      .frame(width: max(0,contentWidth), height:max(0,  geometry.size.height * 0.2))
      .lineLimit(8)
      .fixedSize(horizontal: false, vertical: true) // Ensure the text box grows vertically
  }
  
  func answerButtonsVue(geometry: GeometryProxy) -> some View {
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
                answerButtonVue(answer: answer, buttonWidth: buttonWidth, buttonHeight: buttonHeight, taller: true)
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
          answerButtonVue(answer: answers[0], buttonWidth: contentWidth / 2)
          HStack {
            answerButtonVue(answer: answers[1], buttonWidth: contentWidth / 2.5)
            answerButtonVue(answer: answers[2], buttonWidth: contentWidth / 2.5)
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
                answerButtonVue(answer: answer, buttonWidth: buttonWidth, buttonHeight: buttonHeight)
              }
            }
          }
        }
          .padding(.horizontal)
          .disabled(answerGiven)  // Disable all answer buttons after an answer is given
      )
    }
  }
  
  func answerButtonVue(answer: String, buttonWidth: CGFloat, buttonHeight: CGFloat? = nil, taller: Bool = false) -> some View {
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
  
}
extension QandAScreen {
  
  private func handleDismissal(toRoot:Bool) {
    if toRoot {
      withAnimation(.easeInOut(duration: 0.75)) { // Slower dismissal
        isPresentingDetailView = false
        dismiss()
      }
    } else {
      answerGiven = false //showAnsweredAlert = false
      showHint=false //  showHintAlert = false
    }
  }
  func startTimer() {
    elapsedTime = 0
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      elapsedTime += 1
    }
  }
  
  func stopTimer() {
    gb.totaltime += elapsedTime
    timer?.invalidate()
    timer = nil
  }
  
  func toggleHint() {
    if gb.board[row][col].hint.count > 1  { // guard against short hints
      showHint.toggle()
    }
  }
}
extension QandAScreen { /* actions */
  
  
  func markAnswerCorrect() {
    // selectedAnswer = gb.board[row][col].correct
    answerCorrect = true
    answerGiven = true
    animateBackToBlue = true
    showBorders = true
    gb.cellstate[row][col] = .playedCorrectly
    gb.rightcount += 1
    gb.saveGameBoard()
    chmgr.setStatus(for: gb.board[row][col], index: row*gb.size + col,
                    status: .playedCorrectly)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      animateBackToBlue = false
      
    }
    stopTimer()
  }
  
  func markAnswerIncorrect() {
    // if let sel = selectedAnswer, sel != //gb.board[row][col].correct {
    answerCorrect = false
    answerGiven = true
    showCorrectAnswer = true
    showCorrectAnswer = false
    showBorders = true
    gb.cellstate[row][col] = .playedIncorrectly
    gb.wrongcount += 1
    gb.saveGameBoard()
    chmgr.setStatus(for: gb.board[row][col], index: row*gb.size + col, status: .playedIncorrectly)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      
    }
    stopTimer()
  }
  
  func handleGimmee() {
    gb.playcount += 1
    stopTimer()
    dismiss()
  }
  
  func handleGimmeeAll() {
    gb.playcount += 1
    stopTimer()
    dismiss()
  }
  
  func handleAnswerSelection(answer: String) {
    selectedAnswer = answer
    answerCorrect = (answer == gb.board[row][col].correct)
    answerGiven = true
    if answerCorrect == false {
      showCorrectAnswer = true
      gb.cellstate[row][col] = .playedIncorrectly
      gb.wrongcount += 1
      gb.saveGameBoard()
      chmgr.setStatus(for: gb.board[row][col], index: row*gb.size + col, status: .playedIncorrectly)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        showCorrectAnswer = false
        showBorders = true
      }
    }
    else {
      animateBackToBlue = true
      chmgr.setStatus(for: gb.board[row][col], index: row*gb.size + col,status: .playedCorrectly)
      gb.cellstate[row][col] = .playedCorrectly
      gb.rightcount += 1
      gb.saveGameBoard()
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        animateBackToBlue = false
        showBorders = true
      }
    }
    stopTimer()
  }
  
  func handlePass() {
    stopTimer()
    dismiss()
  }
  func dismissOverlay() {
    showHint = false
    answerGiven = false
    isPresentingDetailView = false
  }
}
#Preview {
  QandAScreen(row: 0, col: 0,   isPresentingDetailView: .constant(true), chmgr: ChaMan(playData: .mock), gb: GameBoard(size: starting_size,                                                                      topics: Array(MockTopics.mockTopics.prefix(starting_size)), challenges:Challenge.mockChallenges))
  
}
#Preview {
  QandAScreen(row: 0, col: 0,  isPresentingDetailView: .constant(true), chmgr: ChaMan(playData: .mock), gb: GameBoard(size: starting_size,                                                                      topics: Array(MockTopics.mockTopics.prefix(starting_size)), challenges:Challenge.mockChallenges))
  
}

