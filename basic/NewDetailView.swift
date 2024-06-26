import SwiftUI

import SwiftUI

struct DetailChallengeView: View {
    let row: Int
    let col: Int
    
    @Binding var playCount: Int  // Binding to track play count
  @Binding var isPresentingDetailView: Bool
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
  
    @State private var showYellow: Bool = false // holds hint and explanation
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    TopBarView(
                        topic: gb.board[row][col].topic,
                        elapsedTime: formattedElapsedTime,
                        additionalInfo: "Scores will go here",
                        handlePass: handlePass,
                        toggleHint: toggleHint
                    )
                    questionAndAnswersSection(geometry: geometry)
                    Spacer()
                    bottomButtons
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding(.horizontal, 10)
                .padding(.bottom, 30)
                .frame(width: geometry.size.width) // Center the content with padding
                .onAppear(perform: startTimer)
                .onDisappear(perform: stopTimer)
                
                // Black transparent overlay area for hint and explanation
                if showHint || answerGiven {
                    yellowArea(geometry: geometry)
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.3)
                        .background(
                            Color.black.opacity(0.5)
                                .cornerRadius(12)
                                .shadow(radius: 10)
                        )
                        .padding()
                        .transition(.opacity)
                        .animation(.easeInOut, value: showHint || answerGiven)
                }
            }
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
          .foregroundColor(.white)
        Button(action: {
          dismissOverlay()
        }) {
          Text("Dismiss")
            .font(.headline)
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(10)
        }
        .padding(.top, 10)
      } else {
        // not showing hihnt
        if let answerCorrect = answerCorrect {
          Text(answerCorrect ? "Correct" : "Incorrect")
            .font(.headline)
            .foregroundColor(.white)
        }
        if let explanation = gb.board[row][col].explanation, answerGiven && explanation.count > 1 {
          ScrollView {
            Text(explanation)
              .font(.caption)
              .padding(.top, 5)
              .foregroundColor(.white)
          }
        }
        
        //            if showHint {
        //                Text(gb.board[row][col].hint)
        //                    .font(.headline)
        //                    .foregroundColor(.black)
        //            } else if let answerCorrect = answerCorrect {
        //                Text(answerCorrect ? "Correct" : "Incorrect")
        //                    .font(.headline)
        //                    .foregroundColor(.black)
        //            } else {
        //                Text("")
        //            }
        //            if let explanation = gb.board[row][col].explanation, answerGiven {
        //                ScrollView {
        //                    Text(explanation)
        //                        .font(.caption)
        //                        .padding(.top, 5)
        //                        .foregroundColor(.black)
        //                }
        //            }
        //        }
        
        
        Button(action: {
          dismissOverlay()
        }) {
          Text("Dismiss")
            .font(.headline)
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(10)
        }
        .padding(.top, 10)
        
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .center)
      }
    }
  }
        func dismissOverlay() {
            showHint = false
            answerGiven = false
          isPresentingDetailView = false 
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

        func handleAnswerSelection(answer: String) {
            selectedAnswer = answer
            answerCorrect = (answer == gb.board[row][col].correct)
            answerGiven = true

            if answerCorrect == false {
                showCorrectAnswer = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showCorrectAnswer = false
                    showBorders = true
                    gb.cellstate[row][col] = .playedIncorrectly
                }
            } else {
                animateBackToBlue = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    animateBackToBlue = false
                    showBorders = true
                    gb.cellstate[row][col] = .playedCorrectly
                }
            }
            stopTimer()
        }

        func handlePass() {
        
            stopTimer()
          dismiss()
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
                gb.cellstate[row][col] = .playedCorrectly
                gb.saveGameBoard()
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
                    gb.cellstate[row][col] = .playedIncorrectly
                    gb.saveGameBoard()
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
